require 'rails_helper'

RSpec.describe CCR::DailyAttendanceAdapter, type: :adapter do
  let(:retrial) { create(:case_type, :retrial) }

  describe '#attendances' do
    subject { described_class.new(claim).attendances }

    context 'with a scheme 9 claim' do
      let(:claim) { create(:authorised_claim, case_type:) }

      context 'with a trial' do
        let(:case_type) { build(:case_type, :trial) }

        context 'when no daily attendance uplift fees applied' do
          context 'when the trial length for the claim is missing' do
            before { claim.update(actual_trial_length: nil) }

            it { is_expected.to eq 2 }
          end

          context 'when the claim has an actual trial length of 0 days' do
            before { claim.update(actual_trial_length: 0) }

            it { is_expected.to eq 0 }
          end

          context 'when the claim has an actual trial length of 1 day' do
            before { claim.update(actual_trial_length: 1) }

            it { is_expected.to eq 1 }
          end

          context 'when the claim has an actual trial length of 3 days' do
            before { claim.update(actual_trial_length: 3) }

            it { is_expected.to eq 2 }
          end
        end

        context 'when daily attendance uplift fees applied' do
          before do
            claim.actual_trial_length = 51
            create(:basic_fee, :daf_fee, claim:, quantity: 38, rate: 1.0)
            create(:basic_fee, :dah_fee, claim:, quantity: 10, rate: 1.0)
            create(:basic_fee, :daj_fee, claim:, quantity: 1, rate: 1.0)
          end

          it 'returns sum of daily attendance fee types plus 2 (included in basic fee)' do
            is_expected.to eq 51
          end
        end
      end

      context 'with a retrial' do
        let(:case_type) { build(:case_type, :retrial) }

        context 'when no daily attendance uplift fees applied' do
          context 'when the retrial length for the claim is missing' do
            before { claim.update(retrial_actual_length: nil) }

            it { is_expected.to eq 2 }
          end

          context 'when the claim has an actual retrial length of 0 days' do
            before { claim.update(retrial_actual_length: 0) }

            it { is_expected.to eq 0 }
          end

          context 'when the claim has an actual retrial length of 1 day' do
            before { claim.update(retrial_actual_length: 1) }

            it { is_expected.to eq 1 }
          end

          context 'when the claim has an actual retrial length of 3 days' do
            before { claim.update(retrial_actual_length: 3) }

            it { is_expected.to eq 2 }
          end
        end
      end
    end

    context 'with a scheme 10 claim' do
      let(:claim) do
        create(
          :authorised_claim,
          :agfs_scheme_10,
          case_type:,
          form_step: :case_details,
          offence: create(:offence, :with_fee_scheme_ten)
        )
      end

      context 'with a trial' do
        let(:case_type) { build(:case_type, :trial) }

        context 'when no daily attendance uplift fee (2+) applied' do
          context 'when the trial length for the claim is missing' do
            before { claim.update(actual_trial_length: nil) }

            it { is_expected.to eq 1 }
          end

          context 'when the claim has an actual trial length of 0 days' do
            before { claim.update(actual_trial_length: 0) }

            it { is_expected.to eq 0 }
          end

          context 'when the claim has an actual trial length of 1 day' do
            before { claim.update(actual_trial_length: 1) }

            it { is_expected.to eq 1 }
          end

          context 'when the claim has an actual trial length of 2 days' do
            before { claim.update(actual_trial_length: 2) }

            it { is_expected.to eq 1 }
          end
        end

        context 'when daily attendance uplift fees applied' do
          before do
            claim.actual_trial_length = 10
            create(:basic_fee, :dat_fee, claim:, quantity: 9, rate: 1.0)
          end

          it 'returns sum of daily attendance fee types plus 1 (included in basic fee)' do
            is_expected.to eq 10
          end
        end
      end

      context 'with a retrial' do
        let(:case_type) { build(:case_type, :retrial) }

        context 'when no daily attendance uplift fee (2+) applied' do
          context 'when the retrial length for the claim is missing' do
            before { claim.update(retrial_actual_length: nil) }

            it { is_expected.to eq 1 }
          end

          context 'when the claim has an actual retrial length of 0 days' do
            before { claim.update(retrial_actual_length: 0) }

            it { is_expected.to eq 0 }
          end

          context 'when the claim has an actual retrial length of 1 day' do
            before { claim.update(retrial_actual_length: 1) }

            it { is_expected.to eq 1 }
          end

          context 'when the claim has an actual retrial length of 3 days' do
            before { claim.update(retrial_actual_length: 3) }

            it { is_expected.to eq 1 }
          end
        end
      end
    end
  end

  describe '.attendances_for' do
    subject(:attendances_for) { described_class.attendances_for(claim) }

    let(:claim) { build(:authorised_claim) }
    let(:adapter) { instance_double described_class }

    before do
      allow(described_class).to receive(:new).with(claim).and_return adapter
      allow(adapter).to receive(:attendances)

      attendances_for
    end

    it { expect(adapter).to have_received(:attendances) }
  end
end
