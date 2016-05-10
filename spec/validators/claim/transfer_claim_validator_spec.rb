require 'rails_helper'
require_relative '../validation_helpers'
require_relative 'shared_examples_for_advocate_litigator'

module Claim
  describe(Claim::TransferClaimValidator) do

    include ValidationHelpers
    include_context "force-validation"

    let(:claim) { build :transfer_claim }
    let(:transfer_detail) { build :transfer_detail, claim: claim }

    include_examples "common advocate litigator validations", :litigator
    include_examples "common litigator validations"

    describe 'case_type' do
      it 'errors if nil' do
        expect_invalid_attribute_with_message(claim, :case_type, nil, 'blank')
      end
    end

    describe 'court' do
      it 'errors if nil' do
        expect_invalid_attribute_with_message(claim, :court, nil, 'blank')
      end
    end

    context 'litigator type' do
      it 'errors if not new or original' do
        expect_invalid_attribute_with_message(claim, :litigator_type, 'xxx', 'invalid')
      end

      it 'is valid if new or original' do
        expect_valid_attribute(claim, :litigator_type, 'new')
        expect_valid_attribute(claim, :litigator_type, 'original')
      end
    end

    context 'elected_case' do
      it 'errors if nil' do
        expect_invalid_attribute_with_message(claim, :elected_case, nil, 'invalid')
      end

      it 'is valid if true or false' do
        expect_valid_attribute(claim, :elected_case, true)
        expect_valid_attribute(claim, :elected_case, false)
      end
    end

    context 'transfer_stage_id' do
      it 'errors if invalid id' do
        expect_invalid_attribute_with_message(claim, :transfer_stage_id, 33, 'invalid')
      end

      it 'is valid if a valid value' do
        expect_valid_attribute(claim, :transfer_stage_id, 40)
      end
    end

    context 'transfer_date' do
      it 'errors if blank' do
        expect_invalid_attribute_with_message(claim, :transfer_date, nil, 'blank')
      end

      it 'errors if in future' do
        expect_invalid_attribute_with_message(claim, :transfer_date, 2.days.from_now, 'check_not_in_future')
      end

      it 'errors if too far in the past' do
        expect_invalid_attribute_with_message(claim, :transfer_date, 6.years.ago, 'check_not_too_far_in_past')
      end

      it 'is valid if in the recent past' do
        expect_valid_attribute(claim, :transfer_date, 2.months.ago)
      end
    end

    context 'trial dates validation' do
      context 'case type: trial' do

        let(:claim) { build :transfer_claim, :trial }

        # TODO: remove? not really necessary as inherits base claim validator method which is already spec'ed
        # ARE TRIAL DETAILS REALLY REQUIRED?
        context 'first_day_of_trial' do
          xit 'is invalid if not present' do
            expect_invalid_attribute_with_message(claim, :first_day_of_trial, nil, 'blank')
          end
          xit 'is invalid if after trial concluded date' do
            expect_invalid_attribute_with_message(claim, :first_day_of_trial, 1.day.ago, 'check_other_date')
          end
        end

        # TODO: remove? not really necessary as inherits base claim validator method which is already spec'ed
        # ARE TRIAL DETAILS REALLY REQUIRED?
        context 'trial_concluded_at' do
          xit 'is invalid if not present' do
            expect_invalid_attribute_with_message(claim, :trial_concluded_at, nil, 'blank')
          end
          xit 'is invalid if before the trial start date' do
            claim.first_day_of_trial = 5.days.ago
            expect_invalid_attribute_with_message(claim, :trial_concluded_at, 6.days.ago, 'check_other_date')
          end
        end

        # TODO: remove? not really necessary as inherits base claim validator method which is already spec'ed
        # ARE TRIAL DETAILS REALLY REQUIRED?
        context 'estimated trial length' do
          xit 'is invalid if absent' do
            expect_invalid_attribute_with_message(claim, :estimated_trial_length, nil, 'blank')
          end
          xit 'is invalid if negative' do
            expect_invalid_attribute_with_message(claim, :estimated_trial_length, -1, 'invalid')
          end
        end

      end
    end

    context 'case_conclusion' do
      it 'is valid if nil' do
        expect_valid_attribute claim, :case_conclusion_id, nil
      end

      it 'is valid if a valid case conclusion id' do
        expect_valid_attribute claim, :case_conclusion_id, 20
      end

      it 'errors if not a valid case conclusion id' do
        expect_invalid_attribute_with_message(claim, :case_conclusion_id, 44, 'invalid')
      end
    end

    context 'transfer_details combination' do

      let(:claim) do
        claim = Claim::TransferClaim.new(litigator_type: 'new', elected_case: false, transfer_stage_id: 50, case_conclusion_id: 10)
        claim.form_step = 2
        claim.force_validation = true
        claim
      end

      it 'errors if details are an invalid combination' do
        expect(claim).not_to be_valid
        expect(claim.errors[:transfer_detail]).to include('invalid_combo')
      end

      it 'does not error if details are a valid combo' do
        claim.case_conclusion_id = 20
        claim.valid?
        expect(claim.errors.keys).not_to include(:transfer_detail)
      end
    end

  end
end
