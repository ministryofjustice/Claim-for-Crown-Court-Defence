require 'rails_helper'
require File.dirname(__FILE__) + '/../validation_helpers'
require_relative 'shared_examples_for_fee_validators_spec'

module Fee
  describe GraduatedFeeValidator do
    include ValidationHelpers
    include_context 'force-validation'

    let(:claim) { build :litigator_claim }
    let(:fee) { build :graduated_fee }

    before(:each) do
      allow(fee).to receive(:perform_validation?).and_return(true)
    end

    describe '#validate_claim' do
      it { should_error_if_not_present(fee, :claim, 'blank') }
    end

    describe '#validate_fee_type' do
      it { should_error_if_not_present(fee, :fee_type, 'blank') }
    end

    context 'assume valid fee' do
      it 'fee is valid' do
        expect(fee).to be_valid
      end
    end

    describe '#validate_quantity' do
      # note: before validation hook sets nil to zero
      it { should_error_if_not_present(fee, :quantity, 'numericality') }

      it 'numericality, must be between 1 and 999999' do
        fee.quantity = 1
        expect(fee).to be_valid
        fee.quantity = 99999
        expect(fee).to be_valid
        fee.quantity = 0
        expect(fee).to_not be_valid
        fee.quantity = 100000
        expect(fee).to_not be_valid
      end
    end

    describe '#validate_amount' do
      # note: before validation hook sets nil to zero
      it { should_error_if_not_present(fee, :amount, 'numericality') }

      it 'numericality, must be at least 0.01' do
        fee.amount = 0.01
        expect(fee).to be_valid
        fee.amount = 0.00999
        expect(fee).to_not be_valid
        expect(fee.errors[:amount]).to eq ['numericality']
      end
    end

    describe 'absence of unnecessary attributes' do
      it 'should validate absence of warrant issued date' do
        fee.warrant_issued_date = Date.today
        expect(fee).not_to be_valid
      end
      it 'should validate absence of warrant executed date' do
        fee.warrant_executed_date = Date.today
        expect(fee).not_to be_valid
      end
      it 'should validate absence of case-type-fee-sub-type' do
        fee.sub_type_id = 2
        expect(fee).not_to be_valid
      end
      it 'should validate absence of case numbers' do
        fee.case_numbers = 'T20150111,T20150222'
        expect(fee).not_to be_valid
      end
    end

    include_examples 'common fee date validations'
  end
end
