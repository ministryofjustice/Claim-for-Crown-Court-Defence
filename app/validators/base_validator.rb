class BaseValidator < ActiveModel::Validator

  CASE_NUMBER_PATTERN ||= /^[AST](199|20\d)\d{5}$/i

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

  def attr_present?(attribute)
    !attr_nil?(attribute)
  end

  def attr_zero?(attribute)
    @record.__send__(attribute) == 0
  end

  def attr_blank?(attribute)
    @record.__send__(attribute).blank?
  end

  def validate_presence(attribute, message)
    return if already_errored_date?(attribute)
    add_error(attribute, message) if attr_blank?(attribute)
  end

  def already_errored_date?(attribute)
    is_gov_uk_date?(attribute) && already_errored?(attribute)
  end

  def is_gov_uk_date?(attribute)
    @record.respond_to?(:_gov_uk_dates) && attribute.in?(@record._gov_uk_dates)
  end

  def already_errored?(attribute)
    @record.errors[attribute].any?
  end

  def validate_absence(attribute, message)
    if attr_present?(attribute)
      clear_pre_existing_error(attribute) if is_gov_uk_date?(attribute)
      add_error(attribute, message) unless attr_blank?(attribute)
    end
  end

  def clear_pre_existing_error(attribute)
    @record.errors[attribute].clear
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

  def validate_not_after(date, attribute, message)
    return if attr_nil?(attribute) || date.nil?
    add_error(attribute, message) if @record.__send__(attribute) > date.to_date
  end

  def validate_not_before(date, attribute, message)
    return if attr_nil?(attribute)|| date.nil?
    add_error(attribute, message) if @record.__send__(attribute) < date.to_date
  end

  def validate_has_role(object, role_or_roles, error_message_key, error_message)
    return if object.nil?

    roles = *role_or_roles
    unless roles.any? { |role| object.is?(role) }
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

  def validate_amount_less_than_item_max(attribute, message = 'item_max_amount')
    validate_float_numericality(attribute, nil, Settings.max_item_amount, message)
  end

  def validate_amount_less_than_claim_max(attribute, message = 'claim_max_amount')
    validate_float_numericality(attribute, nil, Settings.max_claim_amount, message)
  end

  def validate_presence_and_numericality(field, minimum: 0, allow_blank: false)
    validate_presence(field, 'blank') unless allow_blank
    validate_float_numericality(field, minimum, nil, 'numericality')
    validate_amount_less_than_item_max(field)
  end

  def validate_vat_numericality(field, lower_than_field:, allow_blank: true)
    validate_presence_and_numericality(field, minimum: 0, allow_blank: allow_blank)
    validate_amount_greater_than(field, lower_than_field, 'greater_than')
  end

  def validate_one_place_of_decimals(field)
    value = @record.__send__(field)
    rounded = value.round(1)
    unless value == rounded
      add_error(field, 'decimal')
    end
  end
end
