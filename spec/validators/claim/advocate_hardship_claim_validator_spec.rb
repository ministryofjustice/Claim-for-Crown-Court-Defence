require 'rails_helper'
require_relative 'shared_examples_for_advocate_litigator'
require_relative 'shared_examples_for_step_validators'

RSpec.describe Claim::AdvocateHardshipClaimValidator, type: :validator do
  include_context 'force-validation'
  include_context 'seed-fee-schemes'

  let(:claim) { create(:advocate_hardship_claim) }

  include_examples 'common advocate litigator validations', :advocate, case_type: false
  include_examples 'advocate claim case concluded at'
  include_examples 'advocate claim external user role'
  include_examples 'advocate claim creator role'
  include_examples 'advocate claim supplier number'

  context 'case_type_id' do
    before { claim.case_type_id = 1 }

    it { should_error_with(claim, :case_type_id, 'present') }
  end

  context 'case_stage' do
    let(:eligible_case_stages) { create_list(:case_stage, 2) }
    let(:ineligible_case_stage) { create(:case_stage, roles: %w[lgfs]) }

    before do
      claim.case_stage = nil
      allow(claim).to receive(:eligible_case_stages).and_return(eligible_case_stages)
    end

    context 'when not present' do
      before { claim.case_stage = nil }

      it { should_error_with(claim, :case_stage, 'blank') }
    end

    context 'when present but ineligible' do
      before { claim.case_stage = ineligible_case_stage }

      it { should_error_with(claim, :case_stage, 'inclusion') }
    end

    context 'when present and eligible' do
      before { claim.case_stage = eligible_case_stages.first }

      it { should_not_error(claim, :case_stage) }
    end
  end

  context 'advocate_category' do
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

    context 'when estimated trial length not present' do
      before { claim.estimated_trial_length = nil }

      it { should_error_with(claim, :estimated_trial_length, 'blank') }
    end

    context 'when estimated trial length less than 0' do
      before { claim.estimated_trial_length = -1 }

      it { should_error_with(claim, :estimated_trial_length, 'hardship_invalid') }
    end

    context 'when first day of trial not present' do
      before { claim.first_day_of_trial = nil }

      it { should_error_with(claim, :first_day_of_trial, 'blank') }
    end

    context 'when first day of trial over 10 years ago' do
      before { claim.first_day_of_trial = Date.today - 10.years - 1.day }

      it { should_error_with(claim, :first_day_of_trial, 'check_not_too_far_in_past') }
    end

    context 'when first day of trial in the future' do
      before { claim.first_day_of_trial = Date.today + 1.day }

      it { should_error_with(claim, :first_day_of_trial, 'check_not_in_future') }
    end

    context 'when first day of trial after trial_concluded_at' do
      before do
        claim.trial_concluded_at = Date.today - 1.day
        claim.first_day_of_trial = claim.trial_concluded_at + 1.day
      end

      it { should_error_with(claim, :first_day_of_trial, 'check_other_date') }
      it { should_error_with(claim, :trial_concluded_at, 'check_other_date') }
    end

    context 'when first day of trial before earliest rep order date' do
      before { claim.first_day_of_trial = claim.earliest_representation_order_date - 1.day }

      it { should_error_with(claim, :first_day_of_trial, 'check_not_earlier_than_rep_order') }
    end
  end

  context 'when retrial_details required' do
    let(:case_type) { build(:case_type, is_fixed_fee: false, requires_retrial_dates: true) }

    before do
      claim.form_step = 'case_details'
      allow(claim).to receive(:case_type).and_return(case_type)
    end

    context 'with invalid trial details' do
      context 'when trial start after trial end' do
      end

      context 'when estimated trial length not present' do
        before { claim.estimated_trial_length = nil }

        it { should_error_with(claim, :estimated_trial_length, 'blank') }
      end

      context 'when estimated trial length less than zero' do
        before { claim.estimated_trial_length = -1 }

        it { should_error_with(claim, :estimated_trial_length, 'invalid') }
      end

      context 'when actual trial length not present' do
        before { claim.actual_trial_length = nil }

        it { should_error_with(claim, :actual_trial_length, 'blank') }
      end

      context 'when actual trial length less than zero' do
        before { claim.actual_trial_length = -1 }

        it { should_error_with(claim, :actual_trial_length, 'invalid') }
      end

      context 'when actual trial length does not match dates' do
        before do
          claim.estimated_trial_length = 10
          claim.first_day_of_trial = Date.today - 1.month
          claim.trial_concluded_at = claim.first_day_of_trial + 9.days
          claim.actual_trial_length = 11
        end

        it { should_error_with(claim, :actual_trial_length, 'too_long') }
      end

      context 'when first day of trial not present' do
        before { claim.first_day_of_trial = nil }

        it { should_error_with(claim, :first_day_of_trial, 'blank') }
      end

      context 'when first day of trial over 10 years ago' do
        before { claim.first_day_of_trial = Date.today - 10.years - 1.day }

        it { should_error_with(claim, :first_day_of_trial, 'check_not_too_far_in_past') }
      end

      context 'when first day of trial in the future' do
        before { claim.first_day_of_trial = Date.today + 1.day }

        it { should_error_with(claim, :first_day_of_trial, 'check_not_in_future') }
      end

      context 'when first day of trial after trial_concluded_at' do
        before do
          claim.first_day_of_trial = Date.today
          claim.trial_concluded_at = claim.first_day_of_trial - 1.day
        end

        it { should_error_with(claim, :first_day_of_trial, 'check_other_date') }
        it { should_error_with(claim, :trial_concluded_at, 'check_other_date') }
      end

      context 'when trial concluded at not present' do
        before { claim.trial_concluded_at = nil }

        it { should_error_with(claim, :trial_concluded_at, 'blank') }
      end
    end

    context 'with invalid retrial details' do
      context 'when estimated retrial length not present' do
        before { claim.retrial_estimated_length = nil }

        it { should_error_with(claim, :retrial_estimated_length, 'blank') }
      end

      context 'when estimated retrial length less than zero' do
        before { claim.retrial_estimated_length = -1 }

        it { should_error_with(claim, :retrial_estimated_length, 'invalid') }
      end

      context 'when actual retrial length not present' do
        before { claim.retrial_actual_length = nil }

        it { should_not_error(claim, :retrial_actual_length) }
      end

      context 'when actual retrial length less than zero' do
        before { claim.retrial_actual_length = -1 }

        it { should_error_with(claim, :retrial_actual_length, 'invalid') }
      end

      context 'when retrial started at not present' do
        before { claim.first_day_of_trial = nil }

        it { should_error_with(claim, :retrial_started_at, 'blank') }
      end

      context 'when retrial started at over 10 years ago' do
        before { claim.retrial_started_at = Date.today - 10.years - 1.day }

        it { should_error_with(claim, :retrial_started_at, 'check_not_too_far_in_past') }
      end

      context 'when retrial started at in the future' do
        before { claim.retrial_started_at = Date.today + 1.day }

        it { should_error_with(claim, :retrial_started_at, 'check_not_in_future') }
      end

      context 'when retrial started at after retrial_concluded_at' do
        before do
          claim.retrial_concluded_at = Date.today - 1.day
          claim.retrial_started_at = claim.retrial_concluded_at + 1.day
        end

        it { should_error_with(claim, :retrial_started_at, 'check_other_date') }
        it { should_error_with(claim, :retrial_concluded_at, 'check_other_date') }
      end

      context 'when retrial started at trial before earliest rep order date' do
        before { claim.retrial_started_at = claim.earliest_representation_order_date - 1.day }

        it { should_error_with(claim, :retrial_started_at, 'check_not_earlier_than_rep_order') }
      end
    end
  end

  context 'offence' do
    before do
      claim.form_step = :offence_details
      claim.offence = nil
    end

    it 'should error if not present' do
      should_error_with(claim, :offence, 'blank')
    end

    context 'when the claim is associated with the new fee reform scheme' do
      let(:claim) { create(:claim, :agfs_scheme_10) }

      it 'should error if not present' do
        should_error_with(claim, :offence, 'new_blank')
      end
    end
  end

  context 'defendant uplift fees aggregation validation' do
    include_examples 'common defendant uplift fees aggregation validation'
    include_examples 'common defendant basic fees aggregation validation'
  end

  include_examples 'common partial validations', {
    case_details: %i[
      case_type_id
      case_stage
      court
      case_number
      case_transferred_from_another_court
      case_concluded_at
      transfer_court
      transfer_case_number
      trial_details
      retrial_details
      trial_cracked_at_third
      trial_fixed_notice_at
      trial_fixed_at
      trial_cracked_at
      supplier_number
    ],
    defendants: [],
    offence_details: %i[offence],
    basic_fees: %i[total advocate_category defendant_uplifts_basic_fees],
    miscellaneous_fees: %i[defendant_uplifts_misc_fees],
    travel_expenses: %i[travel_expense_additional_information],
    supporting_evidence: []
  }
end
