class BaseSubModelValidator < BaseValidator
  # Override this method in the derived class
  def has_many_association_names
    []
  end

  # Override this method in the derived class
  def has_one_association_names
    []
  end

  def validate(record)
    @result = true
    super
    validate_has_many_associations(record)
    validate_has_one_associations(record)
    remove_unnumbered_submodel_errors_from_base_record(record)
    record.errors.empty? && @result
  end

  private

  def validate_has_many_associations(record)
    has_many_association_names.each do |association_name|
      validate_collection_for(record, association_name)
    end
  end

  def validate_has_one_associations(record)
    has_one_association_names.each do |association_name|
      validate_association_for(record, association_name)
    end
  end

  def validate_collection_for(record, association_name)
    collection = record.__send__(association_name)
    collection.each_with_index do |associated_record, i|
      unless associated_record.valid?
        @result = false
        copy_errors_to_base_record(record, association_name, associated_record, i)
      end
    end
  end

  def validate_association_for(record, association_name)
    associated_record = record.__send__(association_name)
    unless associated_record.nil? || associated_record.destroyed?
      @result = false unless associated_record.valid?
    end
  end

  def copy_errors_to_base_record(base_record, association_name, associated_record, i)
    error_prefix = "#{association_name.to_s.singularize}_#{i + 1}"
    associated_record.errors.each do |fieldname, error_message|
      error_suffix = suffix_error_fields? ? "_#{fieldname}" : ''
      base_record_error_key = [error_prefix, error_suffix].join.to_sym
      base_record.errors[base_record_error_key] << error_message
    end
  end

  def remove_unnumbered_submodel_errors_from_base_record(base_record)
    base_record.errors.each do |key, _|
      base_record.errors.delete(key) if is_unnumbered_submodel_error?(key)
    end
  end

  def is_unnumbered_submodel_error?(key)
    key_as_string = key.to_s
    key_as_string =~ /^(.*)\./ && has_many_association_names_for_errors.include?(Regexp.last_match(1).to_sym)
  end

  def has_many_association_names_for_errors
    has_many_association_names
  end

  # Override this method in subclasses for associations that should not generate errors in the format:
  #   supplier_number_3_field
  # and instead should remove the field having errors:
  #   supplier_number_3
  #
  def suffix_error_fields?
    true
  end
end
