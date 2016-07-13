require 'rails_helper'
require File.dirname(__FILE__) + '/validation_helpers'

describe DisbursementValidator do

  include ValidationHelpers

  let(:claim)         { FactoryGirl.build :litigator_claim, force_validation: true }
  let(:disbursement)  { FactoryGirl.build :disbursement, claim: claim }

  describe '#validate_claim' do

    it { should_error_if_not_present(disbursement, :claim, 'blank') }
    
    context "AGFS claims" do
      before { allow(claim).to receive(:agfs?).and_return true }
      it 'should raise invalid fee scheme error' do
        expect(disbursement).to_not be_valid
        expect(disbursement.errors[:claim]).to include 'invalid_fee_scheme'
      end
    end

    context "LGFS claims" do
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
    it { should_error_if_equal_to_value(disbursement, :net_amount, 0,    'numericality') }
    it { should_error_if_equal_to_value(disbursement, :net_amount, -1,   'numericality') }
    it { should_error_if_equal_to_value(disbursement, :net_amount, nil,  'blank') }
    it { should_error_if_equal_to_value(disbursement, :net_amount, 200_001, 'item_max_amount') }
  end

  describe '#validate_vat_amount' do
    it { should_be_valid_if_equal_to_value(disbursement, :vat_amount, 0) }
    it { should_error_if_equal_to_value(disbursement, :vat_amount, -1, 'numericality') }
    it { should_error_if_equal_to_value(disbursement, :vat_amount, nil, 'blank') }
    it { should_error_if_equal_to_value(disbursement, :vat_amount, 200_001, 'item_max_amount') }

    context 'vat greater than net amount' do
      before do
        disbursement.net_amount = 5
      end
      it { should_error_if_equal_to_value(disbursement, :vat_amount, 10, 'greater_than') }
    end
  end

end

