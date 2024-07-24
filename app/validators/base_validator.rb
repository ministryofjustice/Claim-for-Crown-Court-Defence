class BaseValidator < ActiveModel::Validator
  CASE_NUMBER_PATTERN = /^[BASTU](199|20\d)\d{5}$/i
  CASE_URN_PATTERN = /^[A-Za-z0-9]{1,20}$/i
  CASE_NUMBER_OR_URN_PATTERN = /^[A-Za-z](199|20\d)\d{4,6}$/i

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
    return unless self.class.respond_to?(fields_class_method)

    fields = self.class.__send__(fields_class_method)
    fields.each do |field|
      __send__(:"validate_#{field}")
    end
  end

  private

  def error_message_for(model, attribute, error)
    I18n.t "activerecord.errors.models.#{model}.attributes.#{attribute}.#{error}"
  end

  def attr_nil?(attribute)
    @record.__send__(attribute).nil?
  end

  def attr_present?(attribute)
    !attr_nil?(attribute)
  end

  def attr_zero?(attribute)
    @record.__send__(attribute).zero?
  end

  def attr_blank?(attribute)
    @record.__send__(attribute).blank?
  end

  def validate_presence(attribute, message)
    return if already_errored_date?(attribute)
    add_error(attribute, message) if attr_blank?(attribute)
  end

  # error added to foreign key for govuk-formbuilder error handling
  def validate_belongs_to_object_presence(object, message)
    @record.errors.add(:"#{object}_id", message) if attr_blank?(object)
  end

  def validate_boolean_presence(attribute, message)
    add_error(attribute, message) if attr_nil?(attribute)
  end

  def validate_optional_boolean(attribute, message)
    add_error(attribute, message) unless @record.__send__(attribute).in? [true, false, nil]
  end

  def validate_max_length(attribute, length, message)
    add_error(attribute, message) if @record.__send__(attribute).to_s.size > length
  end

  def attr_or_date_nil(attribute, date)
    attr_nil?(attribute) || date.nil?
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
    return unless attr_present?(attribute)
    delete_errors_for(attribute) if is_gov_uk_date?(attribute)
    add_error(attribute, message) unless attr_blank?(attribute)
  end

  def delete_errors_for(attribute)
    @record.errors.delete(attribute)
  end

  def validate_absence_or_zero(attribute, message)
    return if attr_blank?(attribute)
    return if attr_zero?(attribute)
    add_error(attribute, message)
  end

  def validate_pattern(attribute, pattern, message)
    return if attr_blank?(attribute)
    add_error(attribute, message) unless @record.__send__(attribute).match?(pattern)
  end

  def validate_inclusion(attribute, inclusion_list, message)
    return if attr_nil?(attribute)
    add_error(attribute, message) unless inclusion_list.include?(@record.__send__(attribute))
  end

  def validate_exclusion(attribute, exclusion_list, message)
    return if attr_nil?(attribute)
    add_error(attribute, message) if exclusion_list.include?(@record.__send__(attribute))
  end

  def bounds(lower = nil, upper = nil)
    lower_bound = lower.presence || -infinity
    upper_bound = upper.presence || infinity
    [lower_bound, upper_bound]
  end

  def infinity
    1.0 / 0
  end

  #  TODO: refactor validate_numericality to accept options, for taking floating points
  def base_validate_numericality(attribute, lower_bound, message, upper_bound, to)
    return if attr_nil?(attribute)
    lower_bound, upper_bound = bounds(lower_bound, upper_bound)
    add_error(attribute, message) unless (lower_bound..upper_bound).cover?(@record.__send__(attribute).public_send(to))
  end

  def validate_numericality(attribute, message, lower_bound = nil, upper_bound = nil)
    base_validate_numericality(attribute, lower_bound, message, upper_bound, :to_i)
  end

  def validate_float_numericality(attribute, message, lower_bound = nil, upper_bound = nil)
    base_validate_numericality(attribute, lower_bound, message, upper_bound, :to_f)
  end

  def add_error(attribute, message)
    @record.errors.add(attribute, message)
  end

  def compare_date_with_attribute(date, attribute, message, comparison_operator)
    return if attr_or_date_nil(attribute, date)
    add_error(attribute, message) if @record.__send__(attribute).public_send(comparison_operator, date.to_date)
  end

  def validate_on_or_before(date, attribute, message)
    compare_date_with_attribute(date, attribute, message, :>)
  end

  def validate_on_or_after(date, attribute, message)
    compare_date_with_attribute(date, attribute, message, :<)
  end

  def validate_before(date, attribute, message)
    compare_date_with_attribute(date, attribute, message, :>=)
  end

  def validate_not_in_future(attribute)
    validate_on_or_before(Time.zone.today, attribute, :check_not_in_future) unless allow_future_dates
  end

  def validate_has_role(object, role_or_roles, error_message_key, error_message)
    return if object.nil?

    roles = *role_or_roles
    return if roles.any? { |role| object.is?(role) }
    @record.errors.add(error_message_key, error_message)
  end

  def validate_zero_or_negative(attribute, message)
    return if attr_nil?(attribute)
    add_error(attribute, message) unless @record.__send__(attribute).positive?
  end

  def validate_amount_greater_than(attribute, another_attribute, message)
    return if attr_nil?(attribute) || attr_nil?(another_attribute)
    add_error(attribute, message) if @record.__send__(attribute) > @record.__send__(another_attribute)
  end

  def validate_amount_less_than_item_max(attribute, message = 'item_max_amount')
    validate_float_numericality(attribute, message, nil, Settings.max_item_amount)
  end

  def validate_amount_less_than_claim_max(attribute, message = 'claim_max_amount')
    validate_float_numericality(attribute, message, nil, Settings.max_claim_amount)
  end

  def validate_presence_and_numericality(field, minimum: 0, allow_blank: false)
    validate_presence(field, 'blank') unless allow_blank
    validate_float_numericality(field, 'numericality', minimum, nil)
    validate_amount_less_than_item_max(field)
  end

  def validate_presence_and_numericality_govuk_formbuilder(field, minimum: 0, allow_blank: false)
    validate_presence(field, :blank) unless allow_blank
    validate_float_numericality(field, :numericality, minimum, nil)
    validate_float_numericality(field, :item_max_amount, nil, Settings.max_item_amount)
  end

  def validate_vat_less_than_max(vat_attribute, net_attribute)
    vat_amount = @record.send(vat_attribute) || 0
    net_amount = @record.send(net_attribute) || 0
    add_error(vat_attribute, 'max_vat_amount') if vat_exceeds_max?(vat: vat_amount, net: net_amount)
  end

  def validate_vat_less_than_max_govuk_formbuilder(vat_attribute, net_attribute)
    vat_amount = @record.send(vat_attribute) || 0
    net_amount = @record.send(net_attribute) || 0
    add_error(vat_attribute, :max_vat_amount) if vat_exceeds_max?(vat: vat_amount, net: net_amount)
  end

  def validate_vat_numericality(attribute, lower_than_field:, allow_blank: true)
    validate_presence_and_numericality(attribute, minimum: 0, allow_blank:)
    validate_amount_greater_than(attribute, lower_than_field, 'greater_than')
    validate_vat_less_than_max(attribute, lower_than_field)
  end

  def validate_vat_numericality_govuk_formbuilder(attribute, lower_than_field:, allow_blank: true)
    validate_presence_and_numericality_govuk_formbuilder(attribute, minimum: 0, allow_blank:)
    validate_amount_greater_than(attribute, lower_than_field, :greater_than)
    validate_vat_less_than_max_govuk_formbuilder(attribute, lower_than_field)
  end

  def validate_two_decimals(field)
    value = @record.__send__(field)
    rounded = value.round(2)
    add_error(field, 'decimal') unless value == rounded
  end

  def vat_exceeds_max?(vat:, net:)
    max_vat = VatRate.vat_amount(net, @record.claim.vat_date, calculate: true)
    vat.round(2) > max_vat.round(2)
  end

  def looks_like_a_case_number?(attribute)
    return false if attr_blank?(attribute)
    @record.__send__(attribute).match?(CASE_NUMBER_OR_URN_PATTERN)
  end

  def allow_future_dates
    return false if ENV.fetch('ENV', nil).eql?('production')

    ActiveRecord::Type::Boolean.new.cast(ENV.fetch('ALLOW_FUTURE_DATES', nil))
  end
end
