class Claim::TransferClaimSubModelValidator < Claim::BaseClaimSubModelValidator
  def has_one_association_names_for_steps
    {
      transfer_fee_details: [],
      case_details: [],
      defendants: [],
      offence_details: [],
      transfer_fees: [{ name: :transfer_fee, options: { presence: true } }]
    }
  end

  def has_many_association_names_for_steps
    {
      transfer_fee_details: [],
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
