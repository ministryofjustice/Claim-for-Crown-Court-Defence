require 'rails_helper'

RSpec.describe Fee::InterimFeeValidator, type: :validator do
  # NOTE: before validation hook sets nil to zero
  shared_examples 'quantity numericality between' do |min, max|
    it "valid when between #{min} and #{max}" do
      should_be_valid_if_equal_to_value(fee, :quantity, min)
      should_be_valid_if_equal_to_value(fee, :quantity, max)
    end

    it "invalid when greater than #{max}" do
      should_error_if_equal_to_value(fee, :quantity, max + 1, 'Enter a valid PPE quantity for the interim fee')
    end

    it "invalid when less than #{min}" do
      should_error_if_equal_to_value(fee, :quantity, min - 1, 'Enter a valid PPE quantity for the interim fee')
    end
  end

  let(:fee) { build(:interim_fee) }
  let(:trial_start) { build(:interim_fee, :retrial_start) }
  let(:retrial_start) { build(:interim_fee, :retrial_start) }
  let(:retrial_new_solicitor) { build(:interim_fee, :retrial_new_solicitor) }
  let(:effective_pcmh) { build(:interim_fee, :effective_pcmh) }
  let(:disbursement_fee) { build(:interim_fee, :disbursement) }
  let(:interim_warrant_fee) { build(:interim_fee, :warrant) }

  before do
    allow(fee).to receive(:perform_validation?).and_return(true)
    allow(disbursement_fee).to receive(:perform_validation?).and_return(true)
    allow(interim_warrant_fee).to receive(:perform_validation?).and_return(true)
  end

  context 'assume valid fees' do
    it 'fee is valid' do
      expect(fee).to be_valid
    end

    it 'disbursement_fee is valid' do
      expect(disbursement_fee).to be_valid
    end

    it 'interim_warrant_fee is valid' do
      expect(interim_warrant_fee).to be_valid
    end
  end

  describe '#validate_rate' do
    context 'disbursement fee' do
      it 'invalid if present' do
        should_error_if_equal_to_value(disbursement_fee, :rate, 3, 'present')
      end
    end

    context 'warrant fee' do
      it 'invalid if present' do
        should_error_if_equal_to_value(interim_warrant_fee, :rate, 3, 'present')
      end
    end

    context 'other fee' do
      it 'invalid if present' do
        should_error_if_equal_to_value(fee, :rate, 3, 'present')
      end
    end
  end

  describe '#validate_quantity' do
    let(:quantity_present_error_message) do
      'Do not enter a PPE quantity for the interim fee'
    end

    context 'disbursement fee' do
      it 'valid if nil/zero' do
        should_be_valid_if_equal_to_value(disbursement_fee, :quantity, nil)
        should_be_valid_if_equal_to_value(disbursement_fee, :quantity, 0)
      end

      it 'invalid if present/non-zero' do
        should_error_if_equal_to_value(disbursement_fee, :quantity, 1, quantity_present_error_message)
      end
    end

    context 'warrant fee' do
      it 'valid if nil/zero' do
        should_be_valid_if_equal_to_value(interim_warrant_fee, :quantity, nil)
        should_be_valid_if_equal_to_value(interim_warrant_fee, :quantity, 0)
      end

      it 'invalid if present/non-zero' do
        should_error_if_equal_to_value(interim_warrant_fee, :quantity, 1, quantity_present_error_message)
      end
    end

    context 'effective PCMH fee' do
      include_examples 'quantity numericality between', 0, 99999 do
        let(:fee) { effective_pcmh }
      end
    end

    context 'trial start fee' do
      include_examples 'quantity numericality between', 1, 99999 do
        let(:fee) { trial_start }
      end
    end

    context 'retrial start fee' do
      include_examples 'quantity numericality between', 1, 99999 do
        let(:fee) { retrial_start }
      end
    end

    context 'retrial new solicitor fee' do
      include_examples 'quantity numericality between', 0, 99999 do
        let(:fee) { retrial_new_solicitor }
      end
    end
  end

  describe '#validate_amount' do
    include_examples 'common LGFS amount validations'

    context 'disbursement fee' do
      it 'is invalid if present' do
        disbursement_fee.amount = 3
        expect(disbursement_fee).to be_invalid
        expect(disbursement_fee.errors[:amount]).to eq ['present']
      end
    end

    context 'warrant fee' do
      let(:fee_amount_error_message) do
        'Enter an amount for the (.*?)(interim|warrant) fee'
      end

      it 'is invalid if absent' do
        allow(interim_warrant_fee).to receive(:amount).and_return nil
        expect(interim_warrant_fee).to be_invalid
        expect(interim_warrant_fee.errors[:amount]).to include(match(fee_amount_error_message))
      end
    end
  end

  describe '#fee_type' do
    it 'is not valid when fee type is not an InterimFeeType' do
      expect {
        fee.fee_type = build(:misc_fee_type)
      }.to raise_error ActiveRecord::AssociationTypeMismatch
    end
  end

  describe 'interim warrant fee' do
    it 'validates there are no disbursements in the claim' do
      allow(interim_warrant_fee.claim).to receive(:disbursements).and_return([instance_double(Disbursement)])
      expect(interim_warrant_fee).to be_invalid
      expect(interim_warrant_fee.errors[:disbursements]).to eq ['present']
    end
  end

  describe 'disbursement only interim fee' do
    it 'validates existence of disbursements in the claim' do
      allow(disbursement_fee.claim).to receive(:disbursements).and_return([])
      expect(disbursement_fee).to be_invalid
      expect(disbursement_fee.errors[:disbursements]).to eq ['blank']
    end
  end

  describe 'any other interim fee type' do
    it 'allows having disbursements in the claim' do
      allow(fee.claim).to receive(:disbursements).and_return([instance_double(Disbursement)])
      expect(fee).to be_valid
    end
  end

  describe 'interim warrant fee validations' do
    let(:fee) { interim_warrant_fee }

    include_examples 'common warrant fee validations'

    describe '#validate_warrant_issued_date' do
      it 'is valid if present and in the past' do
        fee.warrant_issued_date = Time.zone.today
        expect(fee).to be_valid
      end
    end
  end
end
