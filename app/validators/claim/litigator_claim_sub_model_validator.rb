class Claim::LitigatorClaimSubModelValidator < Claim::BaseClaimSubModelValidator
  def has_one_association_names_for_steps
    {
      case_details: [],
      defendants: [],
      offence: [],
      fixed_fees: %i[
        fixed_fee
      ],
      graduated_fees: %i[
        graduated_fee
      ],
      misc_fees: [],
      disbursements: [],
      warrant_fee: %i[
        warrant_fee
      ],
      expenses: [],
      supporting_evidence: [],
      additional_information: [],
      other: %i[
        assessment
        certification
      ]
    }.with_indifferent_access
  end

  def has_many_association_names_for_steps
    {
      case_details: [],
      defendants: [],
      offence: [],
      fixed_fees: [],
      graduated_fees: [],
      misc_fees: %i[misc_fees],
      disbursements: %i[disbursements],
      warrant_fee: [],
      expenses: %i[expenses],
      supporting_evidence: %i[documents],
      additional_information: [],
      other: %i[
        messages
        redeterminations
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
