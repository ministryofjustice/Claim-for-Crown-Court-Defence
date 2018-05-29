class Claim::BaseClaimSubModelValidator < BaseSubModelValidator
  # Override this method in the derived class
  def has_many_association_names_for_steps
    {}
  end

  # Override this method in the derived class
  def has_one_association_names_for_steps
    {}
  end

  def validate(record)
    super
    validate_has_many_associations_step_fields(record)
    validate_has_one_association_step_fields(record)
    remove_unnumbered_submodel_errors_from_base_record(record)
    record.errors.empty? && @result
  end

  private

  def validate_all_steps?(record)
    record.from_api? || record.form_step.nil?
  end

  def associations_for_has_many_validations(record)
    # NOTE: keeping existent validation for API purposes
    # The form validations just validate the fields for the current step
    return (has_many_association_names_for_steps[record.form_step] || []) unless validate_all_steps?(record)
    has_many_association_names_for_steps.select do |k, _v|
      record.submission_current_flow.map(&:to_sym).include?(k)
    end.values.flatten
  end

  def validate_has_many_associations_step_fields(record)
    associations_for_has_many_validations(record).each do |association_data|
      validate_presence_of_association(association_data[:name], association_data[:options]) unless record.from_api?
      validate_collection_for(record, association_data[:name])
    end
  end

  def validate_presence_of_association(association_name, options = {})
    validate_presence(association_name, 'blank') if options && options[:presence]
  end

  def associations_for_has_one_validations(record)
    # NOTE: keeping existent validation for API purposes
    # The form validations just validate the fields for the current step
    return (has_one_association_names_for_steps[record.form_step] || []) unless validate_all_steps?(record)
    has_one_association_names_for_steps.select do |k, _v|
      record.submission_current_flow.map(&:to_sym).include?(k)
    end.values.flatten
  end

  def validate_has_one_association_step_fields(record)
    associations_for_has_one_validations(record).each do |association_data|
      validate_presence_of_association(association_data[:name], association_data[:options]) unless record.from_api?
      validate_association_for(record, association_data[:name])
    end
  end

  def has_many_association_names_for_errors
    has_many_association_names_for_steps.values.flatten.each_with_object([]) do |step_data, memo|
      memo << step_data[:name] if step_data[:name]
    end
  end
end
