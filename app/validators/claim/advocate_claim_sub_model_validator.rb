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

  private

  # TODO: override superclass for now but should eventually be promoted
  def validate_has_many_associations_step_fields(record)
    has_many_association_names_for_steps[record.current_step]&.flatten&.each do |association_name|
      validate_collection_for(record, association_name)
    end
  end

  # TODO: override superclass for now but should eventually be promoted
  def validate_has_one_association_step_fields(record)
    has_one_association_names_for_steps[record.current_step]&.flatten&.each do |association_name|
      validate_association_for(record, association_name)
    end
  end

  # TODO: override superclass for now but should eventually be promoted
  def has_many_association_names_for_errors
    has_many_association_names_for_steps.each_with_object([]) { |(_k, v), m| m << v }.flatten
  end
end
