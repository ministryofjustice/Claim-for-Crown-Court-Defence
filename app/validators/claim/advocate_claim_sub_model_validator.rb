class Claim::AdvocateClaimSubModelValidator < Claim::BaseClaimSubModelValidator
  def has_one_association_names_for_steps
    {
      case_details: [],
      defendants: [],
      offence_details: [],
      additional_information: []
    }
  end

  def has_many_association_names_for_steps
    {
      case_details: [],
      defendants: %i[defendants],
      offence_details: [],
      basic_and_fixed_fees: %i[basic_fees fixed_fees],
      miscellaneous_fees: %i[misc_fees],
      travel_expenses: %i[expenses],
      supporting_evidence: %i[documents],
      additional_information: []
    }
  end
end
