class Claim::AdvocateClaimSubModelValidator < Claim::BaseClaimSubModelValidator
  def has_many_association_names_for_steps
    {
      case_details: [],
      defendants: %i[
        defendants
      ],
      offence: [],
      basic_or_fixed_fees: %i[
        basic_fees
        fixed_fees
      ],
      misc_fees: %i[
        misc_fees
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
      case_details: [],
      defendants: [],
      offence: [],
      other: %i[
        assessment
        certifcation
      ]
    }.with_indifferent_access
  end
end
