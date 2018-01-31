class Claim::LitigatorClaimValidator < Claim::BaseClaimValidator
  include Claim::LitigatorCommonValidations

  def self.fields_for_steps
    [
      %i[
        case_type
        court
        case_number
        transfer_court
        transfer_case_number
        advocate_category
        case_concluded_at
      ],
      [],
      %i[offence],
      %i[
        actual_trial_length
        total
      ]
    ]
  end
end
