class Claim::AdvocateInterimClaimSubModelValidator < Claim::BaseClaimSubModelValidator
  def has_one_association_names_for_steps
    {
      case_details: [],
      defendants: [],
      offence_details: [],
      interim_fees: %i[warrant_fee]
    }
  end

  def has_many_association_names_for_steps
    {
      case_details: [],
      defendants: %i[defendants],
      offence_details: [],
      travel_expenses: %i[expenses]
    }
  end
end
