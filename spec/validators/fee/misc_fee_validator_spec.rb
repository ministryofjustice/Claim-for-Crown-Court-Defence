require 'rails_helper'

RSpec.describe Fee::MiscFeeValidator, type: :validator do
  include_context 'force-validation'

  let(:fee) { build(:misc_fee, claim:) }
  let(:fee_code) { fee.fee_type.code }

  # AGFS claims are validated as part of the base_fee_validator_spec
  #
  context 'LGFS claim' do
    let(:claim) { build(:litigator_claim) }

    before do
      fee.clear # reset some attributes set by the factory
      fee.amount = 1.00
    end

    describe '#validate_claim' do
      it { should_error_if_not_present(fee, :claim, 'blank') }
    end

    describe '#validate_fee_type' do
      shared_examples 'post CLAR release validator' do |fee_type_trait|
        let(:fee) { build(:misc_fee, fee_type_trait, claim:, quantity: 0) }
        let(:claim) { build(:litigator_claim, case_type:) }
        let(:case_type) { create(:case_type, :trial) }

        before do
          allow(claim).to receive(:earliest_representation_order_date).and_return(earliest_rep_order_date)
        end

        context "for #{fee_type_trait}" do
          context 'when earliest representation order is before CLAR release' do
            let(:earliest_rep_order_date) { Settings.clar_release_date.end_of_day - 1.day }

            it { expect(fee).not_to be_valid }
            it { expect { fee.valid? }.to change { fee.errors[:fee_type].count }.by(1) }

            it {
              fee.valid?
              expect(fee.errors[:fee_type]).to include('fee_scheme_applicability')
            }
          end

          context 'when earliest representation order is on CLAR release' do
            let(:earliest_rep_order_date) { Settings.clar_release_date.beginning_of_day }

            it { expect { fee.valid? }.not_to change { fee.errors[:fee_type].count } }
          end

          context 'when earliest representation order is nil' do
            let(:earliest_rep_order_date) { nil }

            it { expect { fee.valid? }.not_to change { fee.errors[:fee_type].count } }
          end
        end
      end

      shared_examples 'trial-fee-case-type validator' do |fee_type_trait|
        let(:fee) { build(:misc_fee, fee_type_trait, claim:, quantity: 0) }
        let(:claim) { build(:litigator_claim, case_type:) }

        context "for #{fee_type_trait}" do
          context 'with non trial fee case type' do
            context 'with guilty plea' do
              let(:case_type) { create(:case_type, :guilty_plea) }

              it { expect(fee).not_to be_valid }
              it { expect { fee.valid? }.to change { fee.errors[:fee_type].count }.by(1) }

              it {
                fee.valid?
                expect(fee.errors[:fee_type]).to include('case_type_inclusion')
              }
            end

            context 'with appeal against sentence' do
              let(:case_type) { create(:case_type, :appeal_against_sentence) }

              it { expect(fee).not_to be_valid }
              it { expect { fee.valid? }.to change { fee.errors[:fee_type].count }.by(1) }

              it {
                fee.valid?
                expect(fee.errors[:fee_type]).to include('case_type_inclusion')
              }
            end
          end

          context 'with trial fee case type' do
            let(:case_type) { create(:case_type, :trial) }

            it { expect { fee.valid? }.not_to change { fee.errors[:fee_type].count } }
          end

          context 'with nil case type' do
            let(:case_type) { nil }

            it { expect { fee.valid? }.not_to change { fee.errors[:fee_type].count } }
          end
        end
      end

      shared_examples 'zero quantity permitter' do |fee_type_trait|
        context "for #{fee_type_trait}" do
          let(:fee) { build(:misc_fee, fee_type_trait, claim:) }

          context 'with nil quantity' do
            before { fee.quantity = nil }

            it { expect(fee.quantity).to be_nil }
            it { expect { fee.valid? }.not_to change { fee.errors[:quantity].count } }
          end

          context 'with zero quantity' do
            before { fee.quantity = 0 }

            it { expect(fee.quantity).to be_zero }
            it { expect { fee.valid? }.not_to change { fee.errors[:quantity].count } }
          end
        end
      end

      it { should_error_if_not_present(fee, :fee_type, 'Choose a type for the miscellaneous fee') }

      context 'when validating Unused material (up to 3 hours)' do
        before { create(:misc_fee_type, :miumu) }

        it_behaves_like 'zero quantity permitter', :miumu_fee
        it_behaves_like 'trial-fee-case-type validator', :miumu_fee
        it_behaves_like 'post CLAR release validator', :miumu_fee
      end

      context 'when validating Unused material (over 3 hours)' do
        before { create(:misc_fee_type, :miumo) }

        it_behaves_like 'zero quantity permitter', :miumo_fee
        it_behaves_like 'trial-fee-case-type validator', :miumo_fee
        it_behaves_like 'post CLAR release validator', :miumo_fee
      end
    end

    include_examples 'common LGFS amount validations'

    context 'override validation of fields from the superclass validator' do
      let(:superclass) { described_class.superclass }

      it 'quantity' do
        expect_any_instance_of(superclass).not_to receive(:validate_quantity)
        fee.valid?
      end

      it 'rate' do
        expect_any_instance_of(superclass).not_to receive(:validate_rate)
        fee.valid?
      end

      it 'amount' do
        expect_any_instance_of(superclass).not_to receive(:validate_amount)
        fee.valid?
      end
    end

    describe '#validate_evidence_provision_fee' do
      let(:fee_type) { build(:misc_fee_type, :mievi) }

      before { allow(fee).to receive(:fee_type).and_return(fee_type) }

      %w[45 90].each do |value|
        it "will be valid if amount is £#{value}" do
          should_be_valid_if_equal_to_value(fee, :amount, value)
        end
      end

      it 'will error if passed a decimal amount' do
        should_error_if_equal_to_value(fee, :amount, '45.10', 'Evidence provision fee can only be £45 or £90')
      end

      it 'will error is passed a zero amount' do
        should_error_if_equal_to_value(fee, :amount, '0', 'Evidence provision fee can only be £45 or £90')
      end
    end

    describe '#validate_case_numbers' do
      # NOTE: no case uplift misc fees exist
      context 'for a non Case Uplift fee type' do
        before do
          allow(fee.fee_type).to receive(:case_uplift?).and_return(false)
        end

        it 'is valid if case_numbers is absent' do
          should_be_valid_if_equal_to_value(fee, :case_numbers, nil)
        end

        it 'errors if case_numbers is present' do
          should_error_if_equal_to_value(fee, :case_numbers, '123',
                                         'Case numbers for the miscellaneous fee are not allowed')
        end
      end
    end
  end
end
