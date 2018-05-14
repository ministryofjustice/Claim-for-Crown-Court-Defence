class Claim::InterimClaimSubModelValidator < Claim::BaseClaimSubModelValidator
  def has_one_association_names_for_steps
    {
      case_details: [],
      defendants: [],
      offence_details: [],
      interim_fees: [{ name: :interim_fee }]
    }
  end

  def has_many_association_names_for_steps
    {
      case_details: [],
      defendants: [{ name: :defendants, options: { presence: true } }],
      offence_details: [],
      interim_fees: [{ name: :disbursements }],
      travel_expenses: [{ name: :expenses }],
      supporting_evidence: [{ name: :documents }]
    }
  end
end
