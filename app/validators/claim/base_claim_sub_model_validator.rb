class Claim::BaseClaimSubModelValidator < BaseSubModelValidator

  private

  def validate_has_many_associations_step_fields(record)
    if record.from_web?
      has_many_association_names_for_steps[record.current_step_index] || []
    else
      has_many_association_names_for_steps.flatten
    end.each do |association_name|
      validate_collection_for(record, association_name)
    end
  end

  def validate_has_one_association_step_fields(record)
    if record.from_web?
      has_one_association_names_for_steps[record.current_step_index] || []
    else
      has_one_association_names_for_steps.flatten
    end.each do |association_name|
      validate_association_for(record, association_name)
    end
  end
end
