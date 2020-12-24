require 'rails_helper'
require_relative 'shared_examples_for_advocate_litigator'
require_relative 'shared_examples_for_step_validators'

RSpec.describe Claim::AdvocateClaimValidator, type: :validator do
  include_context 'force-validation'
  include_context 'seed-fee-schemes'

  let(:claim) { create(:advocate_claim) }

  include_examples 'common advocate litigator validations', :advocate
  include_examples 'advocate claim case concluded at'
  include_examples 'advocate claim external user role'
  include_examples 'advocate claim creator role'
  include_examples 'advocate claim supplier number'

  context 'advocate_category' do
    default_valid_categories = ['QC', 'Led junior', 'Leading junior', 'Junior alone']
    fee_reform_valid_categories = ['QC', 'Leading junior', 'Junior']
    fee_reform_invalid_categories = default_valid_categories - fee_reform_valid_categories
    all_valid_categories = (default_valid_categories + fee_reform_valid_categories).uniq

    # API behaviour is different because fixed fees
    # do not require an offence so cannot rely on
    # either offence or rep order date to determine valid
    # advocate categories
    context 'when claim from API' do
      context 'with scheme 9 offence' do
        let(:claim) { create(:api_advocate_claim, :with_scheme_nine_offence) }

        default_valid_categories.each do |category|
          it "should not error if '#{category}' specified" do
            claim.advocate_category = category
            should_not_error(claim, :advocate_category)
          end
        end
      end

      context 'with scheme 10 offence' do
        let(:claim) { create(:api_advocate_claim, :with_scheme_ten_offence) }

        fee_reform_valid_categories.each do |category|
          it "should not error if '#{category}' specified" do
            claim.advocate_category = category
            should_not_error(claim, :advocate_category)
          end
        end
      end

      context 'with no offence (fixed fee case type)' do
        let(:claim) { create(:api_advocate_claim, :with_no_offence) }

        all_valid_categories.each do |category|
          it "should not error if '#{category}' specified" do
            claim.advocate_category = category
            should_not_error(claim, :advocate_category)
          end
        end
      end
    end

    context 'when on the basic fees step' do
      include_examples 'advocate category validations', factory: :advocate_claim, form_step: 'basic_fees'
    end

    context 'when on the fixed fees step' do
      include_examples 'advocate category validations', factory: :advocate_claim, form_step: 'fixed_fees'
    end
  end

  context 'offence' do
    before do
      claim.form_step = :offence_details
      claim.offence = nil
    end

    it 'should error if not present for non-fixed fee case types' do
      allow(claim.case_type).to receive(:is_fixed_fee?).and_return(false)
      should_error_with(claim, :offence, 'blank')
    end

    it 'should NOT error if not present for fixed fee case types' do
      allow(claim.case_type).to receive(:is_fixed_fee?).and_return(true)
      should_not_error(claim, :offence)
    end

    context 'when the claim is associated with the new fee reform scheme' do
      let(:claim) { create(:claim, :agfs_scheme_10) }

      context 'and case type is for non-fixed fees' do
        before do
          allow(claim.case_type).to receive(:is_fixed_fee?).and_return(false)
        end

        it 'should error if not present' do
          should_error_with(claim, :offence, 'new_blank')
        end
      end

      context 'and case type is for fixed fees' do
        before do
          allow(claim.case_type).to receive(:is_fixed_fee?).and_return(true)
        end

        it 'should NOT error if not present' do
          should_not_error(claim, :offence)
        end
      end
    end
  end

  context 'defendant uplift fees aggregation validation' do
    include_examples 'common defendant uplift fees aggregation validation'
    include_examples 'common defendant basic fees aggregation validation'
  end

  include_examples 'common partial validations', {
    case_details: %i[
      case_type
      court
      case_number
      case_transferred_from_another_court
      transfer_court
      transfer_case_number
      estimated_trial_length
      actual_trial_length
      retrial_estimated_length
      retrial_actual_length
      trial_cracked_at_third
      trial_fixed_notice_at
      trial_fixed_at
      trial_cracked_at
      trial_dates
      retrial_started_at
      retrial_concluded_at
      case_concluded_at
      supplier_number
    ],
    defendants: [],
    offence_details: %i[offence],
    basic_fees: %i[total advocate_category defendant_uplifts_basic_fees],
    fixed_fees: %i[total advocate_category defendant_uplifts_fixed_fees],
    miscellaneous_fees: %i[defendant_uplifts_misc_fees],
    travel_expenses: %i[travel_expense_additional_information],
    supporting_evidence: []
  }
end
