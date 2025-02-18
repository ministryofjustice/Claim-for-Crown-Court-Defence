require 'rails_helper'

RSpec.describe Fee::TransferFeeValidator, type: :validator do
  include_context 'force-validation'

  let(:claim) { build(:transfer_claim, claim_trait, defendants: create_list(:defendant, 1)) }
  let(:fee) { build(:transfer_fee, claim:) }
  let(:claim_trait) { :not_requiring_ppe }

  before do
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

  include_examples 'common LGFS amount validations'

  describe 'absence of unnecessary attributes' do
    it 'validates absence of warrant issued date' do
      fee.warrant_issued_date = Time.zone.today
      expect(fee).not_to be_valid
    end

    it 'validates absence of warrant executed date' do
      fee.warrant_executed_date = Time.zone.today
      expect(fee).not_to be_valid
    end

    it 'validates absence of sub type id' do
      fee.sub_type_id = 2
      expect(fee).not_to be_valid
    end

    it 'validates absence of case numbers' do
      fee.case_numbers = 'T20140111,T20140222'
      expect(fee).not_to be_valid
    end
  end

  describe '#validate_quantity' do
    let(:fee) { build(:transfer_fee, claim:) }

    context 'when transfer details require PPE to be supplied' do
      let(:claim_trait) { :requiring_ppe }

      it { should_be_valid_if_equal_to_value(fee, :quantity, 1) }
      it { should_error_if_equal_to_value(fee, :quantity, 0, 'Enter a valid PPE quantity for the transfer fee') }
    end

    context 'when transfer details does not require PPE to be supplied' do
      it { should_be_valid_if_equal_to_value(fee, :quantity, 0) }
      it { should_be_valid_if_equal_to_value(fee, :quantity, 1) }
    end
  end
end
