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

    it { is_expected.to all(be_a(CaseType)) }
    it { is_expected.to all(have_attributes(is_fixed_fee: false)) }
  end

  describe '#cleaner' do
    # TODO: advocate_hardship_claim - could be shared with advocate claim
    context 'clears inapplicable fields' do
      context 'for cracked trial details' do
        let(:claim) { build(:advocate_hardship_claim, case_type: case_type, **cracked_details) }

        let(:cracked_details) {
          {
            trial_fixed_notice_at: Date.current - 3.days,
            trial_fixed_at: Date.current - 1,
            trial_cracked_at: Date.current,
            trial_cracked_at_third: 'final_third'
          }
        }

        before { claim.save }

        context 'when guilty plea with cracked case details saved' do
          let(:case_type) { create(:case_type, :guilty_plea) }

          it 'removes the cracked details' do
            expect(claim).to have_attributes(
                                trial_fixed_notice_at: nil,
                                trial_fixed_at: nil,
                                trial_cracked_at: nil,
                                trial_cracked_at_third: nil
                              )
          end
        end

        context 'when cracked trial claim created via API with cracked case details' do
          let(:case_type) { create(:case_type, :cracked_trial) }

          it 'does not remove the cracked details' do
            expect(claim).to have_attributes(
                                trial_fixed_notice_at: cracked_details[:trial_fixed_notice_at],
                                trial_fixed_at: cracked_details[:trial_fixed_at],
                                trial_cracked_at: cracked_details[:trial_cracked_at],
                                trial_cracked_at_third: cracked_details[:trial_cracked_at_third]
                              )
          end
        end

        context 'when cracked before retrial claim created via API with cracked case details' do
          let(:case_type) { create(:case_type, :cracked_before_retrial) }

          it 'does not remove the cracked details' do
            expect(claim).to have_attributes(
                                trial_fixed_notice_at: cracked_details[:trial_fixed_notice_at],
                                trial_fixed_at: cracked_details[:trial_fixed_at],
                                trial_cracked_at: cracked_details[:trial_cracked_at],
                                trial_cracked_at_third: cracked_details[:trial_cracked_at_third]
                              )
          end
        end
      end
    end
  end
end
