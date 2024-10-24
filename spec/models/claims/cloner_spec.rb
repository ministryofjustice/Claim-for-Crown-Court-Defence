require 'rails_helper'

RSpec.shared_examples 'common defendants cloning tests' do
  it 'clones the defendants' do
    expect(@cloned_claim.defendants.count).to eq(1)
    expect(@cloned_claim.defendants.map(&:name)).to eq(@original_claim.defendants.map(&:name))
  end

  it 'clones the defendant\'s representation orders' do
    orig_rep_orders = representation_orders_for(@original_claim.defendants)
    rep_orders = representation_orders_for(@cloned_claim.defendants)

    expect(rep_orders.size).to eq(2)
    expect(rep_orders.map(&:maat_reference).sort).to eq(orig_rep_orders.map(&:maat_reference).sort)
  end

  it 'does not clone the uuids of defendants' do
    expect(@cloned_claim.defendants.map(&:uuid).sort).to_not match_array(@original_claim.defendants.map(&:uuid).sort)
  end

  it 'does not clone the uuids of representation orders' do
    cloned_claim_uuids = representation_orders_for(@cloned_claim.defendants).map(&:uuid)
    rejected_claim_uuids = representation_orders_for(@original_claim.defendants).map(&:uuid)
    expect(cloned_claim_uuids.sort).to_not match_array(rejected_claim_uuids.sort)
  end
end

RSpec.describe Claims::Cloner do
  context 'ensure we are excluding fee associations' do
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
    context 'non-rejected_claims' do
      it 'tests the functionality in the new way' do
        non_rejected_claim = build(:claim)
        allow(non_rejected_claim).to receive(:rejected?).and_return(false)
        expect {
          non_rejected_claim.clone_rejected_to_new_draft
        }.to raise_error(ArgumentError)
      end
    end

    context 'rejected_claims' do
      before(:all) do
        @current_user = create(:external_user)
        @original_claim = create_rejected_claim
        @cloned_claim = @original_claim.clone_rejected_to_new_draft(author_id: @current_user.id)
      end

      after(:all) do
        clean_database
      end

      it 'creates a draft claim' do
        expect(@cloned_claim).to be_draft
      end

      it 'does not clone last_submitted_at' do
        expect(@cloned_claim.last_submitted_at).to be_nil
      end

      it 'does not clone last_edited_at' do
        expect(@cloned_claim.last_edited_at).to be_nil
      end

      it 'does not clone original_submission_date' do
        expect(@cloned_claim.original_submission_date).to be_nil
      end

      it 'does not clone the uuid' do
        expect(@cloned_claim.reload.uuid).to_not eq(@original_claim.uuid)
      end

      it 'does not clone the uuids of fees' do
        expect(@cloned_claim.fees.map { |fee| fee.reload.uuid }).to_not match_array(@original_claim.fees.map { |fee| fee.reload.uuid })
      end

      it 'does not clone the uuids of expenses' do
        expect(@cloned_claim.expenses.map { |expense| expense.reload.uuid }).to_not match_array(@original_claim.expenses.map { |expense| expense.reload.uuid })
      end

      it 'does not clone the uuids of documents' do
        expect(@cloned_claim.documents.map { |document| document.reload.uuid }).to_not match_array(@original_claim.documents.map { |document| document.reload.uuid })
      end

      include_examples 'common defendants cloning tests'

      it 'does not clone the uuids of expense dates attended' do
        cloned_claim_uuids = @cloned_claim.expenses.map(&:reload).map { |e| e.dates_attended.map { |date| date.reload.uuid } }.flatten
        rejected_claim_uuids = @original_claim.expenses.map(&:reload).map { |e| e.dates_attended.map { |date| date.reload.uuid } }.flatten
        expect(cloned_claim_uuids).to_not match_array(rejected_claim_uuids)
      end

      it 'does not clone the uuids of fee dates attended' do
        cloned_claim_uuids = @cloned_claim.fees.map(&:reload).map { |e| e.dates_attended.map { |date| date.reload.uuid } }.flatten
        rejected_claim_uuids = @original_claim.fees.map(&:reload).map { |e| e.dates_attended.map { |date| date.reload.uuid } }.flatten
        expect(cloned_claim_uuids).to_not match_array(rejected_claim_uuids)
      end

      it 'clones the fees' do
        expect(@cloned_claim.fees.count).to eq(@original_claim.fees.count)

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

      it 'clones the disbursements' do
        expect(@cloned_claim.disbursements.size).to eq(@original_claim.disbursements.size)
        expect(@cloned_claim.disbursements.map(&:net_amount)).to eq(@original_claim.disbursements.map(&:net_amount))
        expect(@cloned_claim.disbursements.map(&:vat_amount)).to eq(@original_claim.disbursements.map(&:vat_amount))
      end

      it 'clones the documents' do
        expect(@cloned_claim.documents.count).to eq(1)
        expect(@cloned_claim.documents.count).to eq(@original_claim.documents.count)
      end

      it 'stores the original claim ID in the new cloned claim' do
        expect(@cloned_claim.clone_source_id).to eq(@original_claim.id)
      end

      it 'generates a new form_id for the cloned claim' do
        expect(@cloned_claim.form_id).to_not be_blank
        expect(@cloned_claim.form_id).to_not eq(@original_claim.form_id)
      end

      it 'copies the new form_id to the cloned documents' do
        expect(@cloned_claim.documents.map { |document| document.reload.form_id }.uniq).to eq([@cloned_claim.form_id])
      end

      it 'does not clone determinations - assessments or redeterminations' do
        expect(@original_claim.redeterminations.count).to eq(1)
        expect(@cloned_claim.redeterminations.count).to eq(0)

        expect(@original_claim.assessment.nil?).to be(false)
        expect(@cloned_claim.assessment.zero?).to be(true)
      end

      it 'does not clone certifications' do
        expect(@original_claim.certification).to_not be_nil
        expect(@cloned_claim.certification).to be_nil
      end

      it 'does not clone the injection attempts' do
        expect(@original_claim.injection_attempts.count).to eq(1)
        expect(@cloned_claim.injection_attempts.count).to eq(0)
      end

      it 'creates the first state transition for the cloned claim' do
        expect(@cloned_claim.claim_state_transitions.count).to eq(1)

        transition = @cloned_claim.last_state_transition
        expect(transition.claim_id).to eq(@cloned_claim.id)
        expect(transition.from).to eq('rejected')
        expect(transition.to).to eq('draft')
        expect(transition.event).to eq('transition_clone_to_draft')
        expect(transition.author_id).to eq(@current_user.id)
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

    include_examples 'common defendants cloning tests'
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
    [].tap do |collection|
      defendants.map { |d| collection << d.representation_orders }
    end.flatten
  end
end
