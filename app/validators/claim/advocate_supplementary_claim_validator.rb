class Claim::AdvocateSupplementaryClaimValidator < Claim::BaseClaimValidator
  include Claim::AdvocateClaimCommonValidations
  include Claim::DefendantUpliftValidations

  def self.fields_for_steps
    {
      case_details: %i[
        court
        case_number
        case_transferred_from_another_court
        transfer_court
        transfer_case_number
        case_concluded_at
        supplier_number
      ],
      defendants: [],
      miscellaneous_fees: %i[advocate_category defendant_uplifts_misc_fees],
      travel_expenses: %i[travel_expense_additional_information],
      supporting_evidence: []
    }
  end

  FEE_VALIDATION_FIELDS = %i[total].freeze
end
