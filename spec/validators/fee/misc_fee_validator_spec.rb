require 'rails_helper'

RSpec.describe Fee::MiscFeeValidator, type: :validator do
  include_context 'force-validation'

  let(:fee) { FactoryBot.build :misc_fee, claim: claim }
  let(:fee_code) { fee.fee_type.code }

  # AGFS claims are validated as part of the base_fee_validator_spec
  #
  context 'LGFS claim' do
    let(:claim) { FactoryBot.build :litigator_claim }

    before(:each) do
      fee.clear   # reset some attributes set by the factory
      fee.amount = 1.00
    end

    describe '#validate_claim' do
      it { should_error_if_not_present(fee, :claim, 'blank') }
    end

    describe '#validate_fee_type' do
      it { should_error_if_not_present(fee, :fee_type, 'blank') }
    end

    include_examples 'common amount validations'

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

    context 'when misc fee is an evidence provision fee' do
      let(:fee_type) { build :misc_fee_type, :mievi }

      before { allow(fee).to receive(:fee_type).and_return(fee_type) }

      %w[45 90].each do |value|
        it "will be valid if amount is £#{value}" do
          should_be_valid_if_equal_to_value(fee, :amount, value)
        end
      end

      it 'will error if passed a decimal amount' do
        should_error_if_equal_to_value(fee, :amount, '45.10', 'incorrect_epf')
      end

      it 'will error is passed a zero amount' do
        should_error_if_equal_to_value(fee, :amount, '0', 'incorrect_epf')
      end
    end

    describe '#validate_case_numbers' do
      # NOTE: no case uplift misc fees exist
      context 'for a non Case Uplift fee type' do
        before(:each) do
          allow(fee.fee_type).to receive(:case_uplift?).and_return(false)
        end

        it 'should error if case_numbers is present' do
          should_error_if_equal_to_value(fee, :case_numbers, '123', 'present')
        end
      end
    end
  end
end
