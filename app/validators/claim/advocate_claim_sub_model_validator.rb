class Claim::AdvocateClaimSubModelValidator < Claim::BaseClaimSubModelValidator
  def has_one_association_names_for_steps
    {
      case_details: [],
      defendants: [],
      offence_details: [],
      fees: %i[
        assessment
        certification
      ]
    }
  end

  def has_many_association_names_for_steps
    {
      case_details: [],
      defendants: [
        :defendants
      ],
      offence_details: [],
      fees: %i[
        basic_fees
        misc_fees
        fixed_fees
        expenses
        messages
        redeterminations
        documents
      ]
    }
  end
end
