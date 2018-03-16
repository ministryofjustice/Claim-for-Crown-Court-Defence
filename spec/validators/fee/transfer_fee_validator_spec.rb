require 'rails_helper'

RSpec.describe Fee::TransferFeeValidator, type: :validator do
  include_context 'force-validation'

  let(:claim) { build(:transfer_claim, :not_requiring_ppe) }
  let(:fee) { build(:transfer_fee, claim: claim) }

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

  include_examples 'common amount validations'

  describe 'absence of unnecessary attributes' do
    it 'validates absence of warrant issued date' do
      fee.warrant_issued_date = Date.today
      expect(fee).to be_invalid
    end

    it 'validates absence of warrant executed date' do
      fee.warrant_executed_date = Date.today
      expect(fee).to be_invalid
    end

    it 'validates absence of sub type id' do
      fee.sub_type_id = 2
      expect(fee).to be_invalid
    end

    it 'validates absence of case numbers' do
      fee.case_numbers = 'T20150111,T20150222'
      expect(fee).to be_invalid
    end
  end

  describe '#validate_quantity' do
    let(:fee) { build(:transfer_fee, claim: claim) }

    context 'when transfer details require PPE to be supplied' do
      let(:claim) { build(:transfer_claim, :requiring_ppe) }

      it { should_be_valid_if_equal_to_value(fee, :quantity, 1) }
      it { should_error_if_equal_to_value(fee, :quantity, 0, 'numericality') }
    end

    context 'when transfer details does not require PPE to be supplied' do
      let(:claim) { build(:transfer_claim, :not_requiring_ppe) }

      it { should_be_valid_if_equal_to_value(fee, :quantity, 0) }
      it { should_be_valid_if_equal_to_value(fee, :quantity, 1) }
    end
  end
end
