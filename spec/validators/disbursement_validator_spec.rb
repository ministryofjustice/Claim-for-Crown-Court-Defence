require 'rails_helper'
require File.dirname(__FILE__) + '/validation_helpers'

describe DisbursementValidator do
  include ValidationHelpers

  let(:claim)         { FactoryGirl.build :claim, force_validation: true }
  let(:disbursement)  { FactoryGirl.build :disbursement, claim: claim }

  describe '#validate_claim' do
    it { should_error_if_not_present(disbursement, :claim, 'blank') }
  end

  describe '#validate_expense_type' do
    it { should_error_if_not_present(disbursement, :disbursement_type, 'blank') }
  end

  describe '#validate_net_amount' do
    it { should_error_if_equal_to_value(disbursement, :net_amount, 0, 'zero_or_negative') }
    it { should_error_if_equal_to_value(disbursement, :net_amount, -1,   'numericality') }
    it { should_error_if_equal_to_value(disbursement, :net_amount, nil,  'blank') }
  end

  describe '#validate_vat_amount' do
    it { should_be_valid_if_equal_to_value(disbursement, :vat_amount, 0) }
    it { should_error_if_equal_to_value(disbursement, :vat_amount, -1, 'numericality') }
    it { should_error_if_equal_to_value(disbursement, :vat_amount, nil, 'blank') }

    context 'vat greater than net amount' do
      before do
        disbursement.net_amount = 5
      end
      it { should_error_if_equal_to_value(disbursement, :vat_amount, 10, 'greater_than') }
    end
  end
end
