require 'rails_helper'
require_relative '../validation_helpers'

describe Fee::MiscFeeValidator do

  include ValidationHelpers
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

    describe '#validate_case_numbers' do
      context 'for a non Case Uplift fee type' do
        before(:each) do
          allow(fee.fee_type).to receive(:case_uplift?).and_return(false)
        end

        it 'should error if case_numbers is present' do
          should_error_if_equal_to_value(fee, :case_numbers, '123', 'present')
        end
      end

      context 'for a Case Uplift fee type' do
        let(:fee_type) do
          instance_double('fee_type', unique_code: 'MIUPL', case_uplift?: true, lgfs?: true, agfs?: false)
        end

        before(:each) do
          allow(fee).to receive(:fee_type).and_return fee_type
        end

        it 'should error if case_numbers is blank' do
          should_error_if_equal_to_value(fee, :case_numbers, '', 'blank')
        end

        it 'should error if case_numbers is invalid' do
          should_error_if_equal_to_value(fee, :case_numbers, '123', 'invalid')
        end

        it 'should be valid for a proper case number' do
          fee.case_numbers = 'A20161234'
          should_not_error(fee, :case_numbers)
        end

        it 'should be valid for several proper case number' do
          fee.case_numbers = 'A20161234,A20158888'
          should_not_error(fee, :case_numbers)
        end

        it 'should be valid for several proper case number even with spaces between them' do
          fee.case_numbers = 'A20161234 , A20158888'
          should_not_error(fee, :case_numbers)
        end

        it 'should error if any case number is invalid' do
          fee.case_numbers = 'A20161234,Z123,A20158888'
          should_error_with(fee, :case_numbers, 'invalid')
        end
      end
    end
  end
end
