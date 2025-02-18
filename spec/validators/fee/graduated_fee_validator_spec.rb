require 'rails_helper'

RSpec.describe Fee::GraduatedFeeValidator, type: :validator do
  include_context 'force-validation'

  let(:claim) { build(:litigator_claim) }
  let(:fee) { build(:graduated_fee) }

  before do
    allow(fee).to receive(:perform_validation?).and_return(true)
  end

  describe '#validate_claim' do
    it { should_error_if_not_present(fee, :claim, 'blank') }

    context 'when the fee is for an interim claim' do
      let(:claim) { build(:interim_claim) }
      let(:fee) { build(:graduated_fee, claim:) }

      it 'does not contain errors on the claim' do
        expect(fee).to be_valid
      end
    end

    context 'when the associated claim has no case type defined' do
      let(:claim) { build(:litigator_claim, case_type: nil) }
      let(:fee) { build(:graduated_fee, claim:) }

      it 'does not container an error on the claim case type' do
        expect(fee).to be_valid
      end
    end

    context 'when the associated claim has a fixed case type' do
      let(:case_type) { build(:case_type, :fixed_fee) }
      let(:claim) { build(:litigator_claim, case_type:) }
      let(:fee) { build(:graduated_fee, claim:) }

      it 'is invalid as it can be associated with this type of claim' do
        expect(fee).not_to be_valid
        expect(fee.errors[:claim]).to include('Fixed fee invalid on non-fixed fee case types')
      end
    end
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
    it 'numericality, must be between 0 and 999999' do
      # NOTE: before validation hook sets nil to zero
      fee.quantity = nil
      expect(fee).to be_valid

      fee.quantity = 0
      expect(fee).to be_valid

      fee.quantity = 1
      expect(fee).to be_valid

      fee.quantity = 99999
      expect(fee).to be_valid

      fee.quantity = 100000
      expect(fee).to_not be_valid
      expect(fee.errors[:quantity]).to eq ['Enter a valid quantity for the graduated fee']

      fee.quantity = -10
      expect(fee).not_to be_valid
      expect(fee.errors[:quantity]).to eq ['Enter a valid quantity for the graduated fee']
    end
  end

  describe 'absence of unnecessary attributes' do
    it 'validates absence of warrant issued date' do
      fee.warrant_issued_date = Time.zone.today
      expect(fee).not_to be_valid
    end

    it 'validates absence of warrant executed date' do
      fee.warrant_executed_date = Time.zone.today
      expect(fee).not_to be_valid
    end

    it 'validates absence of case-type-fee-sub-type' do
      fee.sub_type_id = 2
      expect(fee).not_to be_valid
    end

    it 'validates absence of case numbers' do
      fee.case_numbers = 'T20140111,T20140222'
      expect(fee).not_to be_valid
    end
  end

  include_examples 'common LGFS amount validations'
  include_examples 'common LGFS fee date validations'
end
