class Claim::BaseClaimSubModelValidator < BaseSubModelValidator

  # Override this method in the derived class
  def has_many_association_names_for_steps
    []
  end

  # Override this method in the derived class
  def has_one_association_names_for_steps
    []
  end

  def validate(record)
    super
    validate_has_many_associations_step_fields(record)
    validate_has_one_association_step_fields(record)
    remove_unnumbered_submodel_errors_from_base_record(record)
    record.errors.empty? && @result
  end

  private

  def validate_has_many_associations_step_fields(record)
    has_many_association_names_for_steps[steps_range(record)].flatten.each do |association_name|
      validate_collection_for(record, association_name)
    end
  end

  def validate_has_one_association_step_fields(record)
    has_one_association_names_for_steps[steps_range(record)].flatten.each do |association_name|
      validate_association_for(record, association_name)
    end
  end

  def has_many_association_names_for_errors
    has_many_association_names_for_steps.flatten
  end
end
