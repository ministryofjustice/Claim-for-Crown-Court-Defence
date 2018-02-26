class Claim::InterimClaimSubModelValidator < Claim::BaseClaimSubModelValidator
  def has_one_association_names_for_steps
    {
      case_details: [],
      defendants: [],
      offence_details: [],
      interim_fees: %i[interim_fee]
    }
  end

  def has_many_association_names_for_steps
    {
      case_details: [],
      defendants: %i[defendants],
      offence_details: [],
      interim_fees: %i[disbursements],
      travel_expenses: %i[expenses],
      supporting_evidence: %i[documents]
    }
  end
end
