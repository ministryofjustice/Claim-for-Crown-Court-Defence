require 'rails_helper'

RSpec.shared_examples 'common defendants cloning tests' do
  context 'with defendants' do
    it { expect(@cloned_claim.defendants.count).to eq(1) }
    it { expect(@cloned_claim.defendants.map(&:name)).to eq(@original_claim.defendants.map(&:name)) }
  end

  context 'with representation orders' do
    let(:orig_rep_orders) { representation_orders_for(@original_claim.defendants) }
    let(:rep_orders) { representation_orders_for(@cloned_claim.defendants) }

    it { expect(rep_orders.size).to eq(2) }
    it { expect(rep_orders.map(&:maat_reference).sort).to eq(orig_rep_orders.map(&:maat_reference).sort) }
  end

  it 'does not clone the uuids of defendants' do
    expect(@cloned_claim.defendants.map(&:uuid).sort).not_to match_array(@original_claim.defendants.map(&:uuid).sort)
  end

  it 'does not clone the uuids of representation orders' do
    cloned_claim_uuids = representation_orders_for(@cloned_claim.defendants).map(&:uuid)
    rejected_claim_uuids = representation_orders_for(@original_claim.defendants).map(&:uuid)
    expect(cloned_claim_uuids.sort).not_to match_array(rejected_claim_uuids.sort)
  end
end

RSpec.describe Claims::Cloner do
  context 'with excluded fee associations' do
    let(:claim_types) { [Claim::AdvocateClaim, Claim::AdvocateInterimClaim, Claim::LitigatorClaim, Claim::InterimClaim, Claim::TransferClaim] }
    let(:excluded_associations) { described_class::EXCLUDED_FEE_ASSOCIATIONS }

    it 'checks found fee associations against excluded associations' do
      found_associations = claim_types.inject([]) do |result, klass|
        result | klass.send(:fee_associations)
      end

      expect(found_associations.sort).to eq(excluded_associations.sort)
    end
  end

  describe '#clone_rejected_to_new_draft' do
    subject(:clone) { claim.clone_rejected_to_new_draft(author_id:) }
    
    let(:author_id) { create(:external_user) }

    context 'with a claim that is not rejected' do
      let(:claim) { build(:claim) }

      before { allow(claim).to receive(:rejected?).and_return(false) }

      it { expect { clone }.to raise_error(ArgumentError) }
    end

    context 'with a rejected claim' do
      let(:claim) { create(:interim_claim, :interim_effective_pcmh_fee, :submitted) }

      before do
        create(:certification, claim:)
        claim.allocate!
        claim.reject!
      end

      it { is_expected.to be_draft }
      it { expect(clone.last_submitted_at).to be_nil }
      it { expect(clone.original_submission_date).to be_nil }
      it { expect(clone.uuid).not_to eq claim.uuid }
      it { expect(clone.clone_source_id).to eq(claim.id) }
      it { expect(clone.certification).to be_nil }

      context 'when the claim has been edited' do
        before { claim.touch(:last_edited_at) }

        it { expect(clone.last_edited_at).to be_nil }
      end
    end

    context 'with a rejected claim (old)' do
      before(:all) do
        @current_user = create(:external_user)
        @original_claim = create_rejected_claim
        @cloned_claim = @original_claim.clone_rejected_to_new_draft(author_id: @current_user.id)
      end

      after(:all) do
        clean_database
      end

      it 'does not clone the uuids of fees' do
        expect(@cloned_claim.fees.map { |fee| fee.reload.uuid }).not_to match_array(@original_claim.fees.map { |fee| fee.reload.uuid })
      end

      it 'does not clone the uuids of expenses' do
        expect(@cloned_claim.expenses.map { |expense| expense.reload.uuid }).not_to match_array(@original_claim.expenses.map { |expense| expense.reload.uuid })
      end

      it 'does not clone the uuids of documents' do
        expect(@cloned_claim.documents.map { |document| document.reload.uuid }).not_to match_array(@original_claim.documents.map { |document| document.reload.uuid })
      end

      it_behaves_like 'common defendants cloning tests'

      it 'does not clone the uuids of expense dates attended' do
        cloned_claim_uuids = @cloned_claim.expenses.map(&:reload).map { |e| e.dates_attended.map { |date| date.reload.uuid } }.flatten
        rejected_claim_uuids = @original_claim.expenses.map(&:reload).map { |e| e.dates_attended.map { |date| date.reload.uuid } }.flatten
        expect(cloned_claim_uuids).not_to match_array(rejected_claim_uuids)
      end

      it 'does not clone the uuids of fee dates attended' do
        cloned_claim_uuids = @cloned_claim.fees.map(&:reload).map { |e| e.dates_attended.map { |date| date.reload.uuid } }.flatten
        rejected_claim_uuids = @original_claim.fees.map(&:reload).map { |e| e.dates_attended.map { |date| date.reload.uuid } }.flatten
        expect(cloned_claim_uuids).not_to match_array(rejected_claim_uuids)
      end

      it { expect(@cloned_claim.fees.count).to eq(@original_claim.fees.count) }

      it do
        @cloned_claim.fees.each_with_index do |fee, index|
          expect(fee.amount).to eq(@original_claim.fees[index].amount)
        end
      end

      it 'clones the fee\'s dates attended' do
        expect(@cloned_claim.fees.map { |e| e.dates_attended.count }).to eq(@original_claim.fees.map { |e| e.dates_attended.count })
      end

      it 'clones the expenses' do
        expect(@cloned_claim.expenses.size).to eq(@original_claim.expenses.size)
      end

      it 'clones the expense\'s dates attended' do
        expect(@cloned_claim.expenses.map { |e| e.dates_attended.count }).to eq(@original_claim.expenses.map { |e| e.dates_attended.count })
      end

      it { expect(@cloned_claim.disbursements.size).to eq(@original_claim.disbursements.size) }
      it { expect(@cloned_claim.disbursements.map(&:net_amount)).to eq(@original_claim.disbursements.map(&:net_amount)) }
      it { expect(@cloned_claim.disbursements.map(&:vat_amount)).to eq(@original_claim.disbursements.map(&:vat_amount)) }

      context 'with documents' do
        it { expect(@cloned_claim.documents.count).to eq(1) }
        it { expect(@cloned_claim.documents.count).to eq(@original_claim.documents.count) }
      end

      it { expect(@cloned_claim.form_id).not_to be_blank }
      it { expect(@cloned_claim.form_id).not_to eq(@original_claim.form_id) }

      it 'copies the new form_id to the cloned documents' do
        expect(@cloned_claim.documents.map { |document| document.reload.form_id }.uniq).to eq([@cloned_claim.form_id])
      end

      context 'with redeterminations' do
        it { expect(@original_claim.redeterminations.count).to eq(1) }
        it { expect(@cloned_claim.redeterminations.count).to eq(0) }
      end

      context 'with assessments' do
        it { expect(@original_claim.assessment.nil?).to be(false) }
        it { expect(@cloned_claim.assessment.zero?).to be(true) }
      end

      context 'with injection attempts' do
        it { expect(@original_claim.injection_attempts.count).to eq(1) }
        it { expect(@cloned_claim.injection_attempts.count).to eq(0) }
      end

      context 'with the first state transition for the cloned claim' do
        let(:transition) { @cloned_claim.last_state_transition }

        it { expect(@cloned_claim.claim_state_transitions.count).to eq(1) }

        it { expect(transition.claim_id).to eq(@cloned_claim.id) }
        it { expect(transition.from).to eq('rejected') }
        it { expect(transition.to).to eq('draft') }
        it { expect(transition.event).to eq('transition_clone_to_draft') }
        it { expect(transition.author_id).to eq(@current_user.id) }
      end

      context 'when an error occurs during cloning' do
        subject(:clone_fail) { @original_claim.clone_rejected_to_new_draft(author_id: @current_user.id) }

        before { allow_any_instance_of(Claim::BaseClaim).to receive(:transition_clone_to_draft!).and_raise(RuntimeError) }

        it { expect { clone_fail }.to raise_error(RuntimeError) }
      end
    end
  end

  describe '#clone_details_to_draft' do
    before(:all) do
      @original_claim = create(:claim, :submitted)
      @cloned_claim = @original_claim.clone_details_to_draft(build(:interim_claim))
    end

    after(:all) do
      clean_database
    end

    it 'creates a draft claim' do
      expect(@cloned_claim).to be_draft
    end

    it 'clones the court_id' do
      expect(@cloned_claim.court_id).to eq(@original_claim.court_id)
    end

    it_behaves_like 'common defendants cloning tests'
  end

  # helper methods ---------------
  #
  def create_rejected_claim
    claim = create(:interim_claim, :interim_effective_pcmh_fee, :submitted)

    create(:certification, claim:)

    claim.fees.each do |fee|
      fee.dates_attended << create(:date_attended)
    end

    claim.expenses << create(:expense)
    claim.expenses.each do |expense|
      expense.dates_attended << create(:date_attended)
    end

    create(:disbursement, claim:)
    create(:redetermination, claim:)

    claim.injection_attempts << create(:injection_attempt)
    claim.documents << create(:document, :verified)

    claim.allocate!
    claim.reject!
    claim
  end

  def representation_orders_for(defendants)
    defendants.map(&:representation_orders).flatten
  end
end
