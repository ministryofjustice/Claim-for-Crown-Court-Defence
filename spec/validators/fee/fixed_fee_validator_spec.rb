require 'rails_helper'
require File.dirname(__FILE__) + '/../validation_helpers'

describe Fee::FixedFeeValidator do

  include ValidationHelpers
  include_context 'force-validation'

  let(:fee) { FactoryGirl.build :fixed_fee, claim: claim }
  let(:fee_code) { fee.fee_type.code }

  # AGFS claims are validated as part of the base_fee_validator_spec
  #
  context 'LGFS claim' do
    let(:claim) { FactoryGirl.build :litigator_claim }

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
      let!(:non_parent) { create :fixed_fee_type }
      let!(:parent) { create :fixed_fee_type }
      let!(:child) { create :child_fee_type, :asbo, parent: parent }
      let!(:unrelated_child) { create :child_fee_type, :s74 }
      let!(:fee) { build :fixed_fee, :lgfs, fee_type: parent, sub_type: child, claim: claim }

      context 'should error if fee type has children but fee has no sub type' do
        it 'should be present' do
         should_error_if_not_present(fee, :sub_type, 'blank')
        end

        it 'should NOT error if it is a valid sub type' do
          expect(fee).to be_valid
        end

        it 'should error if not a valid sub type' do
          fee.sub_type = unrelated_child
          expect(fee).to_not be_valid
          expect(fee.errors[:sub_type]).to include( 'invalid' )
        end
      end

      it 'should error if fee type has no children but fee has a sub type' do
        fee.fee_type = non_parent
        expect(fee).to_not be_valid
        expect(fee.errors[:sub_type]).to include 'present'
      end

    end

  end
end
