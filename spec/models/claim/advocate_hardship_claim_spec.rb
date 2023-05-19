RSpec.shared_examples 'trial_cracked_at assigner' do
  subject { claim.trial_cracked_at }

  let(:claim) { build(:advocate_hardship_claim, case_stage:, **cracked_details, assessment:) }
  let(:assessment) { build(:assessment) }

  let(:cracked_details) do
    {
      trial_fixed_notice_at: Date.current - 3.days,
      trial_fixed_at: Date.current - 1,
      trial_cracked_at: nil,
      trial_cracked_at_third: 'final_third'
    }
  end

  context 'when the claim is not yet saved' do
    it { is_expected.to be_nil }
  end

  context 'when the claim is saved' do
    before do
      travel_to(1.week.ago) do
        claim.save
      end
    end

    it 'assigns trial_cracked_at to date saved' do
      is_expected.to eql 1.week.ago.to_date
    end
  end

  context 'when they submit the claim' do
    before do
      travel_to(1.week.ago) do
        claim.save
      end
    end

    it 'assigns trial_cracked_at to current date' do
      expect { claim.submit! }.to change(claim, :trial_cracked_at).from(1.week.ago.to_date).to(Date.today)
    end
  end

  context 'when case worker processes claim' do
    before do
      travel_to(1.week.ago) do
        claim.save
        claim.submit!
      end
    end

    it { is_expected.to eql(1.week.ago.to_date) }

    context 'when allocated' do
      it 'does NOT assign trial_cracked_at' do
        expect { claim.allocate! }.not_to change(claim, :trial_cracked_at)
      end
    end

    context 'when assessed' do
      before { claim.allocate! }

      it 'rejection does NOT assign trial_cracked_at' do
        expect { claim.reject! }.not_to change(claim, :trial_cracked_at)
      end

      it 'authorising an amount does NOT assign trial_cracked_at' do
        expect {
          claim.assessment.update!(fees: random_amount, expenses: random_amount)
          claim.authorise!
        }.not_to change(claim, :trial_cracked_at)
      end
    end
  end
end

RSpec.describe Claim::AdvocateHardshipClaim do
  subject(:claim) { build(:advocate_hardship_claim) }

  it_behaves_like 'a base claim'
  it_behaves_like 'a claim with an AGFS fee scheme factory', FeeSchemeFactory::AGFS
  it_behaves_like 'a claim delegating to case type'
  it_behaves_like 'uses claim cleaner', Cleaners::AdvocateHardshipClaimCleaner

  specify { expect(subject.agfs?).to be_truthy }
  specify { expect(subject.final?).to be_falsey }
  specify { expect(subject.interim?).to be_falsey }
  specify { expect(subject.supplementary?).to be_falsey }
  specify { expect(subject.hardship?).to be_truthy }

  it { is_expected.to delegate_method(:requires_cracked_dates?).to(:case_type) }
  it { is_expected.to accept_nested_attributes_for(:basic_fees) }

  describe '#eligible_case_types' do
    subject { claim.eligible_case_types }

    before { seed_case_types }

    it { is_expected.to all(be_a(CaseType)) }
    it { is_expected.to all(have_attributes(is_fixed_fee: false)) }
  end

  # TODO: hardship claim - can be shared with all advocate claim types
  describe '#eligible_advocate_categories' do
    let(:categories) { double(:mocked_categories_result) }

    specify {
      allow(Claims::FetchEligibleAdvocateCategories).to receive(:for).with(claim).and_return(categories)
      expect(claim.eligible_advocate_categories).to eq(categories)
    }
  end

  # TODO: hardship claim - can be shared with all advocate claim types
  describe '#eligible_misc_fee_types' do
    subject(:call) { claim.eligible_misc_fee_types }

    let(:service) { instance_double(Claims::FetchEligibleMiscFeeTypes) }

    it 'calls eligible misc fee type fetch service' do
      expect(Claims::FetchEligibleMiscFeeTypes).to receive(:new).and_return service
      expect(service).to receive(:call)
      call
    end
  end

  describe '#assign_trial_cracked_at' do
    context 'with cracked trial (After PTPH before trial)' do
      it_behaves_like 'trial_cracked_at assigner' do
        let(:case_stage) { create(:case_stage, :cracked_trial) }
      end
    end

    context 'with cracked before trial (Retrial listed but not started)' do
      it_behaves_like 'trial_cracked_at assigner' do
        let(:case_stage) { create(:case_stage, :retrial_not_started) }
      end
    end
  end
end
