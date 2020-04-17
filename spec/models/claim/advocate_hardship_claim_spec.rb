RSpec.describe Claim::AdvocateHardshipClaim, type: :model do
  it_behaves_like 'a base claim'

  specify { expect(subject.agfs?).to be_truthy }
  specify { expect(subject.final?).to be_falsey }
  specify { expect(subject.interim?).to be_falsey }
  specify { expect(subject.supplementary?).to be_falsey }
  specify { expect(subject.hardship?).to be_truthy }

  it { is_expected.to delegate_method(:requires_cracked_dates?).to(:case_type) }
  it { is_expected.to accept_nested_attributes_for(:basic_fees) }

  describe '#eligible_case_types' do
    subject { claim.eligible_case_types }

    let(:claim) { described_class.new }

    before { seed_case_types }

    it { is_expected.to be_an Array }
    it { is_expected.to all(be_a(CaseStage)) }
  end
end
