require 'rails_helper'
require File.dirname(__FILE__) + '/../validation_helpers'

describe Fee::FixedFeeValidator do

  include ValidationHelpers

  let(:fee) { FactoryGirl.build :fixed_fee, claim: claim }
  let(:fee_code) { fee.fee_type.code }

  # AGFS claims are validated as part of the base_fee_validator_spec
  #
  context 'LGFS claim' do
    let(:claim) { FactoryGirl.build :litigator_claim, force_validation: true }

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

    describe '#validate_amount' do
      it 'should error if amount is equal to zero' do
        should_error_if_equal_to_value(fee, :amount, 0.00, 'invalid')
      end

      it 'should error if amount is less than zero' do
        should_error_if_equal_to_value(fee, :amount, -10.00, 'invalid')
      end
    end

    describe '#validate_sub_type' do
      xit 'should error if fee type has children but fee has no sub type' do
        # TODO
      end
      xit 'should error if fee type has no children but fee has a sub type' do
        # TODO
      end
    end

  end
end
