require 'rails_helper'
require_relative 'shared_examples_for_advocate_litigator'
require_relative 'shared_examples_for_step_validators'

RSpec.describe Claim::AdvocateHardshipClaimValidator, type: :validator do
  include_context 'force-validation'

  let(:claim) { create(:advocate_hardship_claim) }

  include_examples 'common advocate litigator validations', :advocate, case_type: false
  include_examples 'advocate claim case concluded at'
  include_examples 'advocate claim external user role'
  include_examples 'advocate claim creator role'
  include_examples 'advocate claim supplier number'

  context 'when validating case_type_id' do
    before { claim.case_type_id = 1 }

    it { should_error_with(claim, :case_type_id, 'Case type not allowed') }
  end

  context 'when validating case_stage_id' do
    let(:eligible_case_stages) { create_list(:case_stage, 2) }
    let(:ineligible_case_stage) { create(:case_stage, roles: %w[lgfs]) }

    before do
      claim.case_stage = nil
      allow(claim).to receive(:eligible_case_stages).and_return(eligible_case_stages)
    end

    context 'with no case stage' do
      before { claim.case_stage = nil }

      it { should_error_with(claim, :case_stage_id, 'Choose a case stage') }
    end

    context 'with ineligible case stage' do
      before { claim.case_stage = ineligible_case_stage }

      it { should_error_with(claim, :case_stage_id, 'Choose an eligible case stage') }
    end

    context 'with eligible case stage' do
      before { claim.case_stage = eligible_case_stages.first }

      it { should_not_error(claim, :case_stage_id) }
    end
  end

  context 'when validating advocate_category' do
    context 'when on the basic fees step' do
      before { claim.form_step = 'basic_fees' }

      include_examples 'advocate category validations', factory: :advocate_hardship_claim, form_step: 'basic_fees'
    end
  end

  context 'when trial_details required' do
    let(:case_type) { build(:case_type, is_fixed_fee: false, requires_trial_dates: true) }

    before do
      claim.form_step = 'case_details'
      allow(claim).to receive(:case_type).and_return(case_type)
    end

    context 'with estimated trial length not present' do
      before { claim.estimated_trial_length = nil }

      it { should_error_with(claim, :estimated_trial_length, 'Enter an estimated trial length') }
    end

    context 'with estimated trial length less than 0' do
      before { claim.estimated_trial_length = -1 }

      it {
        should_error_with(claim, :estimated_trial_length, 'Enter a whole number of days for the estimated trial length')
      }
    end

    context 'with first day of trial not present' do
      before { claim.first_day_of_trial = nil }

      it { should_error_with(claim, :first_day_of_trial, 'Enter a date for the first day of trial') }
    end

    context 'with first day of trial over 10 years ago' do
      before { claim.first_day_of_trial = Time.zone.today - 10.years - 1.day }

      it { should_error_with(claim, :first_day_of_trial, 'First day of trial cannot be too far in the past') }
    end

    context 'with first day of trial in the future' do
      before { claim.first_day_of_trial = Time.zone.today + 1.day }

      it { should_error_with(claim, :first_day_of_trial, 'First day of trial cannot be in the future') }
    end

    context 'with first day of trial after trial_concluded_at' do
      before do
        claim.trial_concluded_at = Time.zone.today - 1.day
        claim.first_day_of_trial = claim.trial_concluded_at + 1.day
      end

      it { should_error_with(claim, :first_day_of_trial, 'First day of trial cannot be after the trial has concluded') }
      it { should_error_with(claim, :trial_concluded_at, 'Trial concluded cannot be before the First day of trial') }
    end

    context 'with first day of trial before earliest rep order date' do
      before { claim.first_day_of_trial = claim.earliest_representation_order_date - 1.day }

      it {
        should_error_with(claim, :first_day_of_trial, 'Check combination of representation order date and trial dates')
      }
    end
  end

  context 'when retrial_details required' do
    let(:case_type) { build(:case_type, is_fixed_fee: false, requires_retrial_dates: true) }

    before do
      claim.form_step = 'case_details'
      allow(claim).to receive(:case_type).and_return(case_type)
    end

    context 'with invalid trial details' do
      context 'when estimated trial length not present' do
        before { claim.estimated_trial_length = nil }

        it { should_error_with(claim, :estimated_trial_length, 'Enter an estimated trial length') }
      end

      context 'with estimated trial length less than zero' do
        before { claim.estimated_trial_length = -1 }

        it {
          should_error_with(claim, :estimated_trial_length,
                            'Enter a whole number of days for the estimated trial length')
        }
      end

      context 'with actual trial length not present' do
        before { claim.actual_trial_length = nil }

        it { should_error_with(claim, :actual_trial_length, 'Enter an actual trial length') }
      end

      context 'with actual trial length less than zero' do
        before { claim.actual_trial_length = -1 }

        it { should_error_with(claim, :actual_trial_length, 'Enter a whole number of days') }
      end

      context 'with actual trial length does not match dates' do
        before do
          claim.estimated_trial_length = 10
          claim.first_day_of_trial = Time.zone.today - 1.month
          claim.trial_concluded_at = claim.first_day_of_trial + 9.days
          claim.actual_trial_length = 11
        end

        it { should_error_with(claim, :actual_trial_length, 'The actual trial length is too long') }
      end

      context 'with first day of trial not present' do
        before { claim.first_day_of_trial = nil }

        it { should_error_with(claim, :first_day_of_trial, 'Enter a date for the first day of trial') }
      end

      context 'with first day of trial over 10 years ago' do
        before { claim.first_day_of_trial = Time.zone.today - 10.years - 1.day }

        it { should_error_with(claim, :first_day_of_trial, 'First day of trial cannot be too far in the past') }
      end

      context 'with first day of trial in the future' do
        before { claim.first_day_of_trial = Time.zone.today + 1.day }

        it { should_error_with(claim, :first_day_of_trial, 'First day of trial cannot be in the future') }
      end

      context 'with first day of trial after trial_concluded_at' do
        before do
          claim.first_day_of_trial = Time.zone.today
          claim.trial_concluded_at = claim.first_day_of_trial - 1.day
        end

        it {
          should_error_with(claim, :first_day_of_trial, 'First day of trial cannot be after the trial has concluded')
        }

        it { should_error_with(claim, :trial_concluded_at, 'Trial concluded cannot be before the First day of trial') }
      end

      context 'with trial concluded not present' do
        before { claim.trial_concluded_at = nil }

        it { should_error_with(claim, :trial_concluded_at, 'Enter the date on which the trial concluded') }
      end
    end

    context 'when retrial details invalid' do
      context 'with estimated retrial length not present' do
        before { claim.retrial_estimated_length = nil }

        it { should_error_with(claim, :retrial_estimated_length, 'Enter an estimated retrial length') }
      end

      context 'with estimated retrial length less than zero' do
        before { claim.retrial_estimated_length = -1 }

        it {
          should_error_with(claim, :retrial_estimated_length,
                            'Enter a whole number of days for the estimated retrial length')
        }
      end

      context 'with actual retrial length not present' do
        before { claim.retrial_actual_length = nil }

        it { should_not_error(claim, :retrial_actual_length) }
      end

      context 'with actual retrial length less than zero' do
        before { claim.retrial_actual_length = -1 }

        it {
          should_error_with(claim, :retrial_actual_length, 'Enter a whole number of days for the actual retrial length')
        }
      end

      context 'with retrial started at not present' do
        before { claim.first_day_of_trial = nil }

        it { should_error_with(claim, :retrial_started_at, 'Enter a date for the first day of retrial') }
      end

      context 'with retrial started at over 10 years ago' do
        before { claim.retrial_started_at = Time.zone.today - 10.years - 1.day }

        it { should_error_with(claim, :retrial_started_at, 'First day of retrial cannot be too far in the past') }
      end

      context 'with retrial started at in the future' do
        before { claim.retrial_started_at = Time.zone.today + 1.day }

        it { should_error_with(claim, :retrial_started_at, 'First day of retrial cannot be too far in the future') }
      end

      context 'with retrial started at after retrial_concluded_at' do
        before do
          claim.retrial_concluded_at = Time.zone.today - 1.day
          claim.retrial_started_at = claim.retrial_concluded_at + 1.day
        end

        it { should_error_with(claim, :retrial_started_at, 'Check the date for First day of retrial') }
        it { should_error_with(claim, :retrial_concluded_at, 'Check the date for retrial concluded') }
      end

      context 'with retrial started at trial before earliest rep order date' do
        before { claim.retrial_started_at = claim.earliest_representation_order_date - 1.day }

        it { should_error_with(claim, :retrial_started_at, 'Check the date for First day of retrial') }
      end
    end
  end

  context 'when validating offence' do
    before do
      claim.form_step = :offence_details
      claim.offence = nil
    end

    it 'errors with offence not present' do
      should_error_with(claim, :offence, 'Choose an offence')
    end

    context 'with a claim that is associated with the new fee reform scheme' do
      let(:claim) { create(:claim, :agfs_scheme_10) }

      it 'errors if not present' do
        should_error_with(claim, :offence, 'Choose an offence')
      end
    end
  end

  context 'when validating defendant uplift fees aggregation' do
    include_examples 'common defendant uplift fees aggregation validation'
    include_examples 'common defendant basic fees aggregation validation'
  end

  include_examples 'common partial validations', {
    case_details: %i[
      case_type_id
      case_stage_id
      court_id
      case_number
      case_transferred_from_another_court
      case_concluded_at
      transfer_court_id
      transfer_case_number
      trial_details
      retrial_details
      trial_cracked_at_third
      trial_fixed_notice_at
      trial_fixed_at
      trial_cracked_at
      supplier_number
      main_hearing_date
    ],
    defendants: [],
    offence_details: %i[offence],
    basic_fees: %i[total advocate_category defendant_uplifts_basic_fees],
    miscellaneous_fees: %i[defendant_uplifts_misc_fees],
    travel_expenses: %i[travel_expense_additional_information],
    supporting_evidence: []
  }
end
