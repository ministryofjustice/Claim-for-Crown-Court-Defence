class Claim::AdvocateClaimSubModelValidator < Claim::BaseClaimSubModelValidator
  def has_many_association_names_for_steps
    {
      case_details: [],
      defendants: %i[
        defendants
      ],
      offence: [],
      fees: %i[
        basic_fees
        misc_fees
        fixed_fees
        expenses
        messages
        redeterminations
        documents
      ]
    }.with_indifferent_access
  end

  def has_one_association_names_for_steps
    {
      case_details: [],
      defendants: [],
      offence: [],
      fees: %i[
        assessment
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
      # ap "File: #{File.basename(__FILE__)}, Method: #{__method__}, Line: #{__LINE__}"
      # ap "reco.class: #{record.class}"
      # ap "current_step: #{record.current_step}"
      # ap "has_one_associations for step: #{has_one_association_names_for_steps[record.current_step]&.flatten}"
      # # binding.pry
    has_one_association_names_for_steps[record.current_step]&.flatten&.each do |association_name|
      validate_association_for(record, association_name)
    end
  end

  # TODO: override superclass for now but should eventually be promoted
  def has_many_association_names_for_errors
    has_many_association_names_for_steps.each_with_object([]) {|(k,v),m| m << v }.flatten
  end
end
