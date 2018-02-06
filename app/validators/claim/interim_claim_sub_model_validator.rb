class Claim::InterimClaimSubModelValidator < Claim::BaseClaimSubModelValidator
  def has_one_association_names_for_steps
    {
      case_details: [],
      defendants: [],
      offence_details: [],
      fees: %i[
        interim_fee
        assessment
        certification
      ]
    }
  end

  def has_many_association_names_for_steps
    {
      case_details: [],
      defendants: %i[defendants],
      offence_details: [],
      fees: %i[
        disbursements
        messages
        redeterminations
        documents
      ]
    }
  end
end
