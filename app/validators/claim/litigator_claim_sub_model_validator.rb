class Claim::LitigatorClaimSubModelValidator < Claim::BaseClaimSubModelValidator
  def has_one_association_names_for_steps
    {
      case_details: [],
      defendants: [],
      offence_details: [],
      fixed_fees: %i[fixed_fee],
      graduated_fees: %i[graduated_fee]
    }
  end

  def has_many_association_names_for_steps
    {
      case_details: [],
      defendants: %i[defendants],
      offence_details: [],
      miscellaneous_fees: %i[misc_fees],
      disbursements: %i[disbursements],
      travel_expenses: %i[expenses],
      supporting_evidence: %i[documents]
    }
  end
end
