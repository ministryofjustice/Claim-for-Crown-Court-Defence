class Claim::AdvocateClaimSubModelValidator < Claim::BaseClaimSubModelValidator
  def has_one_association_names_for_steps
    {
      case_details: [],
      defendants: [],
      offence_details: []
    }
  end

  def has_many_association_names_for_steps
    {
      case_details: [],
      defendants: [{ name: :defendants, options: { presence: true } }],
      offence_details: [],
      basic_and_fixed_fees: [{ name: :basic_fees }, { name: :fixed_fees }],
      miscellaneous_fees: [{ name: :misc_fees }],
      travel_expenses: [{ name: :expenses }],
      supporting_evidence: [{ name: :documents }]
    }
  end
end
