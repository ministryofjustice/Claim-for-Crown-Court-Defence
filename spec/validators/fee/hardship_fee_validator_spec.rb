require 'rails_helper'

RSpec.describe Fee::HardshipFeeValidator, type: :validator do
  include_context 'force-validation'

  let(:fee) { build :hardship_fee, claim: claim, date: Date.today }

  context 'LGFS claim' do
    let(:claim) { FactoryBot.build :litigator_hardship_claim }

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

    describe '#validate_quantity' do
      it 'be valid if quantity is equal to zero' do
        should_be_valid_if_equal_to_value(fee, :quantity, 0.00)
      end

      it 'adds error if quantity is less than zero' do
        should_error_if_equal_to_value(fee, :quantity, -10.00, 'numericality')
      end
    end

    include_examples 'common LGFS amount validations'
  end
end
