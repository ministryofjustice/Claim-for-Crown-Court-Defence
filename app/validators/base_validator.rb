class BaseValidator < ActiveModel::Validator

  CASE_NUMBER_PATTERN ||= /^[A-Z]{1}\d{8}$/

  # Override this method in the derived class
  def validate_step_fields; end

  def validate(record)
    @record = record
    if @record.perform_validation?
      validate_fields(:fields)
      validate_step_fields
    end
    validate_fields(:mandatory_fields)
  end

  def validate_fields(fields_class_method)
    if self.class.respond_to?(fields_class_method)
      fields = self.class.__send__(fields_class_method)
      fields.each do |field|
        self.__send__("validate_#{field}")
      end
    end
  end

  private

  def error_message_for(model, attribute, error)
    I18n.t "activerecord.errors.models.#{model}.attributes.#{attribute}.#{error}"
  end

  def steps_range(record)
    record.from_api? ? (0..9) : (0..record.current_step_index)
  end

  def attr_nil?(attribute)
    @record.__send__(attribute).nil?
  end

  def attr_zero?(attribute)
    @record.__send__(attribute) == 0
  end

  def attr_blank?(attribute)
    @record.__send__(attribute).blank?
  end

  def validate_presence(attribute, message)
    add_error(attribute, message) if attr_blank?(attribute)
  end

  def validate_absence(attribute, message)
    unless attr_nil?(attribute)
      add_error(attribute, message) unless attr_blank?(attribute)
    end
  end

  def validate_absence_or_zero(attribute, message)
    return if attr_blank?(attribute)
    return if attr_zero?(attribute)
    add_error(attribute, message)
  end

  def validate_pattern(attribute, pattern, message)
    return if attr_blank?(attribute)
    add_error(attribute, message) unless @record.__send__(attribute).match(pattern)
  end

  def validate_inclusion(attribute, inclusion_list, message)
    return if attr_nil?(attribute)
    add_error(attribute, message) unless inclusion_list.include?(@record.__send__(attribute))
  end

  def validate_exclusion(attribute, exclusion_list, message)
    return if attr_nil?(attribute)
    add_error(attribute, message) if exclusion_list.include?(@record.__send__(attribute))
  end

  def bounds(lower=nil,upper=nil)
    lower_bound = lower.blank? ? -infinity : lower
    upper_bound = upper.blank? ? infinity : upper
    return lower_bound, upper_bound
  end

  def infinity
    1.0/0
  end

  #  TODO: refactor validate_numericality to accept options, for taking floating points
  def validate_numericality(attribute, lower_bound=nil, upper_bound=nil, message)
    return if attr_nil?(attribute)
    lower_bound, upper_bound = bounds(lower_bound, upper_bound)
    add_error(attribute, message) unless (lower_bound..upper_bound).include?(@record.__send__(attribute).to_i)
  end

  def validate_float_numericality(attribute, lower_bound=nil, upper_bound=nil, message)
    return if attr_nil?(attribute)
    lower_bound, upper_bound = bounds(lower_bound,upper_bound)
    add_error(attribute, message) unless (lower_bound..upper_bound).include?(@record.__send__(attribute).to_f)
  end

  def add_error(attribute, message)
    @record.errors.add(attribute, message)
  end

  def case_type_in(*case_types)
    case_types.include?(@record.case_type.name) rescue false
  end

  def validate_not_after(date, attribute, message)
    return if attr_nil?(attribute) || date.nil?
    add_error(attribute, message) if @record.__send__(attribute) > date.to_date
  end

  def validate_not_before(date, attribute, message)
    return if attr_nil?(attribute)|| date.nil?
    add_error(attribute, message) if @record.__send__(attribute) < date.to_date
  end

  def validate_has_role(object, role, error_message_key, error_message)
    return if object.nil?
    unless object.is?(role)
      @record.errors[error_message_key] << error_message
    end
  end

  def validate_zero_or_negative(attribute, message)
    return if attr_nil?(attribute)
    add_error(attribute, message) unless @record.__send__(attribute) > 0
  end

  def validate_amount_greater_than(attribute, another_attribute, message)
    return if attr_nil?(attribute) || attr_nil?(another_attribute)
    add_error(attribute, message) if @record.__send__(attribute) > @record.__send__(another_attribute)
  end

end
