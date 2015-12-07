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

  describe 'claim' do
    it { should_error_if_not_present(fee, :claim, 'blank') }
  end

  describe 'fee type' do
    it { should_error_if_not_present(fee, :fee_type, 'blank') }
  end

  describe 'rate' do

    before(:each) do
      daf_fee.claim.actual_trial_length = 10
    end

    context 'with quantity greater than zero' do
      it { should_be_valid_if_equal_to_value(daf_fee, :rate, 450.00) }
      it { should_error_if_equal_to_value(baf_fee, :rate, 0.00, 'baf_invalid') }
      it { should_error_if_equal_to_value(daf_fee, :rate, nil, 'daf_zero') }
      it { should_error_if_equal_to_value(daf_fee, :rate, 0.00, 'daf_zero') }
      it { should_error_if_equal_to_value(daf_fee, :rate, -320, 'daf_zero') }
    end

    context 'with quantity of 0' do
      before(:each) do
        daf_fee.quantity = 0
      end
      it { should_error_if_equal_to_value(daf_fee, :rate, 500.00, 'daf_invalid') }
    end

    # this should be removed after gamma/private beta claims archived/deleted
    context 'for fees entered before rate was reintroduced' do
      it 'should NOT require a rate of more than zero' do
        fee.amount = 255
        fee.rate = nil
        expect(fee).to be_valid
      end
    end

    # this will become default after gamma/private beta claims archived/deleted
    context 'for fees entered after rate was reintroduced' do
      it 'should require a rate of more than zero' do
        fee.amount = nil
        fee.rate = nil
        expect(fee).to_not be_valid
        expect(fee.rate).to eq 0
      end
    end

    # TODO: max_amount removed in later PR - remove?
    # context 'fee with max amount' do
    #   before(:each)       { fee.fee_type.max_amount = 9999 }
    #   it { should_be_valid_if_equal_to_value(fee, :amount, 9999) }
    # end

    # context 'fee with no max amount' do
    #   before(:each)       { fee.fee_type.max_amount = nil }
    #   it { should_be_valid_if_equal_to_value(fee, :amount, 100_000) }
    # end

  end

  describe 'quantity' do

    context 'basic fee (BAF)' do
      expected_error_message = 'baf_qty1'
      it { should_be_valid_if_equal_to_value(baf_fee, :quantity, 1) }
      it { should_error_if_equal_to_value(baf_fee, :quantity, 0,    expected_error_message) }
      it { should_error_if_equal_to_value(baf_fee, :quantity, -1,   expected_error_message) }
      it { should_error_if_equal_to_value(baf_fee, :quantity, nil,  expected_error_message) }
    end

    context 'daily_attendance_3_40 (DAF)' do
      context 'trial length less than three days' do
        it 'should error if trial length is less than three days' do
          daf_fee.claim.actual_trial_length = 2
          should_error_if_equal_to_value(daf_fee, :quantity, 1, 'daf_qty_mismatch')
        end
      end

      context 'trial length greater than three days' do
        it 'should error if quantity greater than 38 regardless of actual trial length' do
          daf_fee.claim.actual_trial_length = 45
          should_error_if_equal_to_value(daf_fee, :quantity, 39, 'daf_qty_mismatch')
        end

        it 'should error if quantity greater than actual trial length less 2 days' do
          daf_fee.claim.actual_trial_length = 20
          should_error_if_equal_to_value(daf_fee, :quantity, 19, 'daf_qty_mismatch')
        end

        it 'should not error if quantity is valid' do
          daf_fee.claim.actual_trial_length = 20
          should_be_valid_if_equal_to_value(daf_fee, :quantity, 17)
          should_be_valid_if_equal_to_value(daf_fee, :quantity, 10)
        end
      end
    end

    context 'daily_attendance_41_50 (DAH)' do
      it 'should error if trial length is less than 40 days' do
          dah_fee.claim.actual_trial_length = 35
          should_error_if_equal_to_value(dah_fee, :quantity, 2, 'dah_qty_mismatch')
      end

      context 'trial length greater than 40 days' do
        it 'should error if greater than trial length less 40 days' do
          dah_fee.claim.actual_trial_length = 45
          should_error_if_equal_to_value(dah_fee, :quantity, 6, 'dah_qty_mismatch')
        end

        it 'should error if greater than 10 days regardless of actual trial length' do
          dah_fee.claim.actual_trial_length = 70
          should_error_if_equal_to_value(dah_fee, :quantity, 12, 'dah_qty_mismatch')
        end

        it 'should not error if valid' do
          dah_fee.claim.actual_trial_length = 55
          should_be_valid_if_equal_to_value(dah_fee, :quantity, 1)
          should_be_valid_if_equal_to_value(dah_fee, :quantity, 10)
        end
      end
    end

    context 'daily attendance 51 plus (DAJ)' do
      context 'trial length less than 51 days' do
        it 'should error if trial length is less than 51 days' do
          daj_fee.claim.actual_trial_length = 50
          should_error_if_equal_to_value(daj_fee, :quantity, 2, 'daj_qty_mismatch')
        end
      end

      context 'trial length greater than 50 days' do
        it 'should error if greater than trial length less 50 days' do
          daj_fee.claim.actual_trial_length = 55
          should_error_if_equal_to_value(daj_fee, :quantity, 6, 'daj_qty_mismatch')
        end

        it 'should not error if valid' do
          daj_fee.claim.actual_trial_length = 60
          should_be_valid_if_equal_to_value(daj_fee, :quantity, 1)
          should_be_valid_if_equal_to_value(daj_fee, :quantity, 10)
        end
      end
    end

    context 'plea and case management hearing' do
      context 'permitted case type' do
        before(:each) do
          claim.case_type = FactoryGirl.build :case_type, :allow_pcmh_fee_type
        end
        it { should_error_if_equal_to_value(pcm_fee, :quantity, 4, 'pcm_invalid') }
        it { should_be_valid_if_equal_to_value(pcm_fee, :quantity, 3) }
        it { should_be_valid_if_equal_to_value(pcm_fee, :quantity, 1) }
      end

      context 'unpermitted case type' do
        before(:each) do
          claim.case_type = FactoryGirl.build :case_type
        end
        it { should_error_if_equal_to_value(pcm_fee, :quantity, 1, 'pcm_invalid') }
        it { should_error_if_equal_to_value(pcm_fee, :quantity, -1, 'pcm_invalid') }
      end
    end

    context 'any other fee' do
      it { should_error_if_equal_to_value(fee, :quantity, -1, 'invalid') }
      it { should_be_valid_if_equal_to_value(fee, :quantity, 99999) }
      it { should_error_if_equal_to_value(fee, :quantity, 100000,    'invalid') }

      it 'should not allow zero if amount is not zero' do
        should_error_if_equal_to_value(fee, :quantity, 0, 'invalid')
      end
    end
  end

end
