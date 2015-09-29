require 'rails_helper'
require File.dirname(__FILE__) + '/date_validation_helpers'

describe FeeValidator do

  include RspecDateValidationHelpers

  let(:claim)                     { FactoryGirl.build :claim, force_validation: true }
  let(:fee)                       { FactoryGirl.build :fee, claim: claim }
  let(:baf_fee)                   { FactoryGirl.build :fee, :baf_fee, claim: claim }
  let(:daf_fee)                   { FactoryGirl.build :fee, :daf_fee, claim: claim }
  let(:dah_fee)                   { FactoryGirl.build :fee, :dah_fee, claim: claim }
  let(:daj_fee)                   { FactoryGirl.build :fee, :daj_fee, claim: claim }
  let(:pcm_fee)                   { FactoryGirl.build :fee, :pcm_fee, claim: claim }

  describe 'fee type' do
    it { should_error_if_not_present(fee, :fee_type, 'Fee type cannot be blank') }
  end


  describe 'amount' do
    before(:each) do
      daf_fee.claim.actual_trial_length = 10
    end
    context 'quantity greater than zero' do
      it { should_be_valid_if_equal_to_value(daf_fee, :amount, 450.00) }
      it { should_be_valid_if_equal_to_value(baf_fee, :amount, 0.00) }
      it { should_error_if_equal_to_value(daf_fee, :amount, nil, 'Fee amount cannot be zero or blank if a fee quantity has been specified, please enter the relevant amount') }
      it { should_error_if_equal_to_value(daf_fee, :amount, 0.00, 'Fee amount cannot be zero or blank if a fee quantity has been specified, please enter the relevant amount') }
      it { should_error_if_equal_to_value(daf_fee, :amount, -320, 'Fee amount cannot be negative') }
    end

    context 'quantity = 0' do
      before(:each) do
        daf_fee.quantity = 0
      end
      it { should_error_if_equal_to_value(daf_fee, :amount, 1.00, 'Fee amounts cannot be specified if the fee quantity is zero') }
    end

    context 'fee with max amount' do
      before(:each)       { fee.fee_type.max_amount = 9999 }

      it { should_be_valid_if_equal_to_value(fee, :amount, 999) }
      it { should_error_if_equal_to_value(fee, :amount, 10000, 'Fee amount exceeds maximum permitted (£9,999) for this fee type') }
    end

    context 'fee with no max amount' do
      before(:each)       { fee.fee_type.max_amount = nil }
      it { should_be_valid_if_equal_to_value(fee, :amount, 100_000) }
    end

  end

  describe 'quantity' do
    context 'basic fee (BAF)' do
      expected_error_message = 'Quantity for basic fee must be exactly one'
      it { should_be_valid_if_equal_to_value(baf_fee, :quantity, 1) }
      it { should_error_if_equal_to_value(baf_fee, :quantity, 0,    expected_error_message) }
      it { should_error_if_equal_to_value(baf_fee, :quantity, -1,   expected_error_message) }
      it { should_error_if_equal_to_value(baf_fee, :quantity, nil,  expected_error_message) }
    end

    context 'daily_attendance_3_40 (DAF)' do
      context 'trial length less than three days' do

        it 'should error if trial length is less than three days' do
          daf_fee.claim.actual_trial_length = 2
          should_error_if_equal_to_value(daf_fee, :quantity, 1, 'Quantity for Daily attendance fee (3 to 40) does not correspond with the actual trial length')
        end
      end

      context 'trial length greater than three days' do
        it 'should error if greater than the actual trial length less three days' do
          daf_fee.claim.actual_trial_length = 20
          should_error_if_equal_to_value(daf_fee, :quantity, 19, 'Quantity for Daily attendance fee (3 to 40) does not correspond with the actual trial length')
        end

        it 'should error if quantiy greater than 37' do
          daf_fee.claim.actual_trial_length = 45
          should_error_if_equal_to_value(daf_fee, :quantity, 38, 'Quantity for Daily attendance fee (3 to 40) does not correspond with the actual trial length')
        end

        it 'should not error if quantity is valid' do
          daf_fee.claim.actual_trial_length = 20
          should_be_valid_if_equal_to_value(daf_fee, :quantity, 17)
          should_be_valid_if_equal_to_value(daf_fee, :quantity, 10)
        end
      end
    end

    context 'daily_attendance_41_50 (DAH)' do
      context 'trial length less than 40 days' do
        it 'should error if trial length is less than 40 days' do
          dah_fee.claim.actual_trial_length = 35
          should_error_if_equal_to_value(dah_fee, :quantity, 2, 'Quantity for Daily attendance fee (41 to 50) does not correspond with the actual trial length')
        end
      end

      context 'trial length greater than 40 days' do
        it 'should error if greater than trial length less 40 days' do
          dah_fee.claim.actual_trial_length = 48
          should_error_if_equal_to_value(dah_fee, :quantity, 9, 'Quantity for Daily attendance fee (41 to 50) does not correspond with the actual trial length')
        end
        it 'should error if greater than 10 days' do
          dah_fee.claim.actual_trial_length = 55
          should_error_if_equal_to_value(dah_fee, :quantity, 12, 'Quantity for Daily attendance fee (41 to 50) does not correspond with the actual trial length')
        end

        it 'should not error if valid' do
          dah_fee.claim.actual_trial_length = 55
          should_be_valid_if_equal_to_value(daf_fee, :quantity, 8)
          should_be_valid_if_equal_to_value(daf_fee, :quantity, 10)
        end
      end
    end

    context 'daily attendance 50 plus (DAJ)' do
      context 'trial length less than 50 days' do
        it 'should error if trial length is less than 40 days' do
          daj_fee.claim.actual_trial_length = 49
          should_error_if_equal_to_value(daj_fee, :quantity, 2, 'Quantity for Daily attendance fee (51+) does not correspond with the actual trial length')
        end
      end
    end

    context 'plea and case management hearing' do
      context 'permitted case type' do
        before(:each) do
          claim.case_type = FactoryGirl.build :case_type, :allow_pcmh_fee_type
        end
        it { should_error_if_equal_to_value(pcm_fee, :quantity, 4, 'Quantity for plea and case management hearing cannot be greater than 3') }
        it { should_be_valid_if_equal_to_value(pcm_fee, :quantity, 3) }
        it { should_be_valid_if_equal_to_value(pcm_fee, :quantity, 1) }
      end

      context 'unpermitted case type' do
        before(:each) do
          claim.case_type = FactoryGirl.build :case_type
        end
        it { should_error_if_equal_to_value(pcm_fee, :quantity, 1, 'PCMH Fees quantity must be zero or blank for this case type') }
        it { should_error_if_equal_to_value(pcm_fee, :quantity, -1, 'PCMH Fees quantity must be zero or blank for this case type') }
      end
    end
  end


end

