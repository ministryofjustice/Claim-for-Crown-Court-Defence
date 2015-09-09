class BaseClaimValidator < ActiveModel::Validator
  def validate(record)
    @record = record
    if @record.perform_validation?
      validate_fields(:fields)
    end
    validate_fields(:mandatory_fields)
  end

  def validate_fields(fields_class_method)
     if self.class.respond_to?(fields_class_method)
        fields = self.class.__send__(fields_class_method)
        fields.each do |field|
          self.send("validate_#{field}")
        end
      end
  end

  private

  def error_message_for(model, attribute, error)
    I18n.t "activerecord.errors.models.#{model}.attributes.#{attribute}.#{error}"
  end


  def validate_presence(attribute, message)
    add_error(attribute, message) if @record.send(attribute).blank?
  end

  def validate_pattern(attribute, pattern, message)
    return if @record.__send__(attribute).nil?
    add_error(attribute, message) unless @record.__send__(attribute).match(pattern)
  end

  def validate_inclusion(attribute, inclusion_list, message)
    return if @record.__send__(attribute).nil?
    add_error(attribute, message) unless inclusion_list.include?(@record.__send__(attribute))
  end

  def validate_numericality(attribute, lower_bound=nil, upper_bound=nil, message)
    infinity = 1.0/0
    lower_bound = lower_bound.blank? ? -infinity : lower_bound
    upper_bound = upper_bound.blank? ? infinity : upper_bound
    add_error(attribute, message) unless (lower_bound..upper_bound).include?(@record.__send__(attribute))
  end

  def add_error(attribute, message)
    @record.errors[attribute] << message
  end

  def case_type_in(*case_types)
    case_types.include?(@record.case_type.name) rescue false
  end

  # throws an error if record.attribute > date
  def validate_not_after(date, attribute, message)
    return if @record.send(attribute).nil? || date.nil?
    add_error(attribute, message) if @record.send(attribute) > date.to_date
  end

  def validate_not_before(date, attribute, message)
    return if @record.send(attribute).nil? || date.nil?
    add_error(attribute, message) if @record.send(attribute) < date.to_date
  end
end
