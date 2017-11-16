class Claim::TransferClaimSubModelValidator < Claim::BaseClaimSubModelValidator
  def has_many_association_names_for_steps
    {
      transfer_details: [],
      case_details: [],
      defendants: %i[
        defendants
      ],
      offence: [],
      transfer_fee: [],
      misc_fees: %i[
        misc_fees
      ],
      disbursements: %i[
        disbursements
      ],
      expenses: %i[
        expenses
      ],
      supporting_evidence: %i[
        documents
      ],
      additional_information: [],
      other: %i[
        redeterminations
        messages
      ]
    }.with_indifferent_access
  end

  def has_one_association_names_for_steps
    {
      transfer_fee: %i[
        transfer_fee
      ],
      other: %i[
        assessment
        certification
      ]
    }.with_indifferent_access
  end
end
