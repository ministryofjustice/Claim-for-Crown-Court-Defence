class Claim::LitigatorClaimSubModelValidator < Claim::BaseClaimSubModelValidator
  def has_one_association_names_for_steps
    {
      case_details: [],
      defendants: [],
      offence_details: [],
      fixed_fees: [{ name: :fixed_fee }],
      graduated_fees: [{ name: :graduated_fee }],
      miscellaneous_fees: [{ name: :interim_claim_info }]
    }
  end

  def has_many_association_names_for_steps
    {
      case_details: [],
      defendants: [{ name: :defendants, options: { presence: true } }],
      offence_details: [],
      miscellaneous_fees: [{ name: :misc_fees }],
      disbursements: [{ name: :disbursements }],
      travel_expenses: [{ name: :expenses }],
      supporting_evidence: [{ name: :documents }]
    }
  end
end
