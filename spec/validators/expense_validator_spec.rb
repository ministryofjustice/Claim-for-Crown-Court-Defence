require 'rails_helper'
require File.dirname(__FILE__) + '/date_validation_helpers'

describe ExpenseValidator do

  include RspecDateValidationHelpers

  let(:claim)                     { FactoryGirl.build :claim, force_validation: true }
  let(:expense)                   { FactoryGirl.build :expense, claim: claim }

  describe 'claim' do
    it { should_error_if_not_present(expense, :claim, 'blank') }
  end

  describe 'expense type' do
    it { should_error_if_not_present(expense, :expense_type, 'blank') }
  end

  describe 'quantity' do
    it { should_be_valid_if_equal_to_value(expense, :quantity, 0) }
    it { should_error_if_equal_to_value(expense, :quantity, -1,   'numericality') }
    it { should_error_if_equal_to_value(expense, :quantity, nil,  "blank") }
  end

  describe 'rate' do
    it { should_be_valid_if_equal_to_value(expense, :rate, 0) }
    it { should_error_if_equal_to_value(expense, :rate, -1,   'numericality') }
    it { should_error_if_equal_to_value(expense, :rate, nil,  'blank') }
  end

end

