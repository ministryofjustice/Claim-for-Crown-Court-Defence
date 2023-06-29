module Claim
  class AdvocateSupplementaryClaimValidator < Claim::BaseClaimValidator
    include Claim::AdvocateClaimCommonValidations
    include Claim::DefendantUpliftValidations

    def self.fields_for_steps
      {
        case_details: %i[
          court_id
          case_number
          case_transferred_from_another_court
          transfer_court_id
          transfer_case_number
          case_concluded_at
          supplier_number
          main_hearing_date
        ],
        defendants: [],
        miscellaneous_fees: %i[advocate_category defendant_uplifts_misc_fees total],
        travel_expenses: %i[travel_expense_additional_information],
        supporting_evidence: []
      }
    end

    FEE_VALIDATION_FIELDS = %i[total].freeze
  end
end
