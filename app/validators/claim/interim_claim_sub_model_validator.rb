class Claim::InterimClaimSubModelValidator < Claim::BaseClaimSubModelValidator
  def has_many_association_names_for_steps
    {
      case_details: [],
      defendants: %i[
        defendants
      ],
      offence: [],
      interim_fee: %i[
        disbursements
      ],
      supporting_evidence: %i[
        documents
      ],
      additional_information: [],
      other: %i[
        messages
        redeterminations
      ]
    }.with_indifferent_access
  end

  def has_one_association_names_for_steps
    {
      interim_fee: %i[
        interim_fee
      ],
      other: %i[
        assessment
        certification
      ]
    }.with_indifferent_access
  end
end
