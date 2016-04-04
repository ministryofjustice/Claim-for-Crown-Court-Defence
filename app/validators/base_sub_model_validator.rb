class BaseSubModelValidator < BaseValidator

  # Override this method in the derived class
  def has_many_association_names
    []
  end

  # Override this method in the derived class
  def has_one_association_names
    []
  end

  # Override this method in the derived class
  def validate_has_many_associations_step_fields(record); end

  # Override this method in the derived class
  def validate_has_one_association_step_fields(record); end


  def validate(record)
    @result = true
    super
    validate_has_many_associations(record)
    validate_has_one_associations(record)
    validate_has_many_associations_step_fields(record)
    validate_has_one_association_step_fields(record)
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
    unless associated_record.nil?
      @result = false unless associated_record.valid?
    end
  end

  def copy_errors_to_base_record(base_record, association_name, associated_record, i)
    error_prefix = "#{association_name.to_s.singularize}_#{i + 1}"
    associated_record.errors.each do |fieldname, error_message|
      base_record_error_key = "#{error_prefix}_#{fieldname}".to_sym
      base_record.errors[base_record_error_key] << error_message
    end
  end

  def remove_unnumbered_submodel_errors_from_base_record(base_record)
    base_record.errors.each do |key, value|
      if is_unnumbered_submodel_error?(key)
        base_record.errors.delete(key)
      end
    end
  end

  def is_unnumbered_submodel_error?(key)
    key_as_string = key.to_s
    key_as_string =~ /^(.*)\./ && has_many_association_names.include?($1.to_sym)
  end

end