class Claim::TransferClaimSubModelValidator < Claim::BaseClaimSubModelValidator
  def has_one_association_names_for_steps
    {
      transfer_fee_details: [],
      case_details: [],
      defendants: [],
      offence_details: [],
      fees: %i[
        transfer_fee
        assessment
        certification
      ]
    }
  end

  def has_many_association_names_for_steps
    {
      transfer_fee_details: [],
      case_details: [],
      defendants: %i[defendants],
      offence_details: [],
      fees: %i[
        misc_fees
        disbursements
        expenses
        messages
        redeterminations
        documents
      ]
    }
  end
end
