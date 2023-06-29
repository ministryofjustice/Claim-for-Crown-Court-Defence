module Claim
  class AdvocateClaimValidator < Claim::BaseClaimValidator
    include Claim::AdvocateClaimCommonValidations
    include Claim::DefendantUpliftValidations

    def self.fields_for_steps
      {
        case_details: %i[
          case_type_id
          court_id
          case_number
          case_transferred_from_another_court
          transfer_court_id
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
          main_hearing_date
        ],
        defendants: [],
        offence_details: %i[offence],
        basic_fees: FEE_VALIDATION_FIELDS + %i[
          advocate_category defendant_uplifts_basic_fees
        ],
        fixed_fees: FEE_VALIDATION_FIELDS + %i[
          advocate_category defendant_uplifts_fixed_fees
        ],
        miscellaneous_fees: %i[defendant_uplifts_misc_fees],
        travel_expenses: %i[travel_expense_additional_information],
        supporting_evidence: []
      }
    end

    FEE_VALIDATION_FIELDS = %i[total].freeze

    private

    def validate_offence
      return if fixed_fee_case?
      validate_presence(:offence, :blank)
    end
  end
end
