class Claim::LitigatorClaimValidator < Claim::BaseClaimValidator
  include Claim::LitigatorCommonValidations

  def self.fields_for_steps
    {
      case_details: %i[
        case_type
        court
        case_number
        transfer_court
        transfer_case_number
        advocate_category
        case_concluded_at
      ],
      defendants: [],
      offence_details: %i[offence],
      fees: %i[
        actual_trial_length
        total
      ]
    }
  end
end
