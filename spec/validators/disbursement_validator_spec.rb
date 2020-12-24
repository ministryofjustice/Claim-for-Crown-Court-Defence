require 'rails_helper'

RSpec.describe DisbursementValidator, type: :validator do
  let(:claim) { build(:litigator_claim, force_validation: true) }
  let(:disbursement) { build(:disbursement, claim: claim, net_amount: 100, vat_amount: 20) }

  describe '#validate_claim' do
    it { should_error_if_not_present(disbursement, :claim, 'blank') }

    context 'AGFS claims' do
      before { allow(claim).to receive(:agfs?).and_return true }
      it 'should raise invalid fee scheme error' do
        expect(disbursement).to be_invalid
        expect(disbursement.errors[:claim]).to include 'invalid_fee_scheme'
      end
    end

    context 'LGFS claims' do
      before { allow(claim).to receive(:agfs?).and_return false }
      it 'should NOT raise invalid fee scheme error' do
        expect(disbursement).to be_valid
      end
    end
  end

  describe '#validate_disbursement_type' do
    it { should_error_if_not_present(disbursement, :disbursement_type, 'blank') }
  end

  describe '#validate_net_amount' do
    it { should_error_if_equal_to_value(disbursement, :net_amount, 0, 'numericality') }
    it { should_error_if_equal_to_value(disbursement, :net_amount, -1, 'numericality') }
    it { should_error_if_equal_to_value(disbursement, :net_amount, nil, 'blank') }
    it { should_error_if_equal_to_value(disbursement, :net_amount, 200_001, 'item_max_amount') }
  end

  describe '#validate_vat_amount' do
    it { should_be_valid_if_equal_to_value(disbursement, :vat_amount, 0) }
    it { should_error_if_equal_to_value(disbursement, :vat_amount, -1, 'numericality') }
    it { should_error_if_equal_to_value(disbursement, :vat_amount, nil, 'blank') }
    it { should_error_if_equal_to_value(disbursement, :vat_amount, 200_001, 'item_max_amount') }

    it 'invalid when vat greater than net amount' do
      disbursement.net_amount = 5
      should_error_if_equal_to_value(disbursement, :vat_amount, 10, 'greater_than')
    end

    context 'vat greater than VAT% of net amount' do
      around do |example|
        travel_to(Time.zone.local(2018, 01, 01)) do
          example.run
        end
      end

      it 'valid when VAT amount is less than or equal to VAT% of NET ' do
        should_be_valid_if_equal_to_value(disbursement, :vat_amount, 20.00)
      end

      it 'valid when rounded VAT amount is less than or equal to VAT% of NET ' do
        should_be_valid_if_equal_to_value(disbursement, :vat_amount, 20.001)
      end

      it 'invalid when VAT amount greater than VAT% of NET' do
        should_error_if_equal_to_value(disbursement, :vat_amount, 20.01, 'max_vat_amount')
      end

      it 'invalid when rounded VAT amount greater than VAT% of NET ' do
        should_error_if_equal_to_value(disbursement, :vat_amount, 20.009, 'max_vat_amount')
      end
    end
  end
end
