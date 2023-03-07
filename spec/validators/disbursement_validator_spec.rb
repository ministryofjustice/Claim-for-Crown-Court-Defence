require 'rails_helper'

RSpec.describe DisbursementValidator, type: :validator do
  let(:claim) { build(:litigator_claim, force_validation: true) }
  let(:disbursement) { build(:disbursement, claim:, net_amount: 100, vat_amount: 20) }

  describe '#validate_claim' do
    it { should_error_if_not_present(disbursement, :claim, 'blank') }

    context 'AGFS claims' do
      before { allow(claim).to receive(:agfs?).and_return true }

      it 'raises invalid fee scheme error' do
        expect(disbursement).to be_invalid
        expect(disbursement.errors[:claim]).to include 'invalid_fee_scheme'
      end
    end

    context 'LGFS claims' do
      before { allow(claim).to receive(:agfs?).and_return false }

      it 'does not raise invalid fee scheme error' do
        expect(disbursement).to be_valid
      end
    end
  end

  describe '#validate_disbursement_type' do
    before { disbursement.disbursement_type = nil }

    it { should_error_if_not_present(disbursement, :disbursement_type_id, 'Choose a type for the disbursement') }
  end

  describe '#validate_net_amount' do
    it { should_error_if_equal_to_value(disbursement, :net_amount, 0, 'Enter a valid net amount for the disbursement') }

    it {
      should_error_if_equal_to_value(disbursement, :net_amount, -1, 'Enter a valid net amount for the disbursement')
    }

    it { should_error_if_equal_to_value(disbursement, :net_amount, nil, 'Enter a net amount for the disbursement') }

    it {
      should_error_if_equal_to_value(disbursement, :net_amount, 200_001,
                                     'The net amount exceeds the limit for the disbursement')
    }
  end

  describe '#validate_vat_amount' do
    let(:max_vat_amount_error_message) do
      'VAT amount for the expense exceeds current VAT rate'
    end

    it { should_be_valid_if_equal_to_value(disbursement, :vat_amount, 0) }

    it {
      should_error_if_equal_to_value(disbursement, :vat_amount, -1, 'Enter a valid VAT amount for the disbursement')
    }

    it { should_error_if_equal_to_value(disbursement, :vat_amount, nil, 'Enter a VAT amount for the disbursement') }

    it {
      should_error_if_equal_to_value(disbursement, :vat_amount, 200_001,
                                     'VAT amount exceeds the limit for the disbursement')
    }

    it 'invalid when vat greater than net amount' do
      disbursement.net_amount = 5
      should_error_if_equal_to_value(disbursement, :vat_amount, 10, max_vat_amount_error_message)
    end

    context 'vat greater than VAT% of net amount' do
      before { travel_to(Time.zone.local(2018, 01, 01)) }

      it 'valid when VAT amount is less than or equal to VAT% of NET' do
        should_be_valid_if_equal_to_value(disbursement, :vat_amount, 20.00)
      end

      it 'valid when rounded VAT amount is less than or equal to VAT% of NET' do
        should_be_valid_if_equal_to_value(disbursement, :vat_amount, 20.001)
      end

      it 'invalid when VAT amount greater than VAT% of NET' do
        should_error_if_equal_to_value(disbursement, :vat_amount, 20.01, max_vat_amount_error_message)
      end

      it 'invalid when rounded VAT amount greater than VAT% of NET' do
        should_error_if_equal_to_value(disbursement, :vat_amount, 20.009, max_vat_amount_error_message)
      end
    end
  end
end
