class BaseClaimValidator < ActiveModel::Validator


   def validate(record)
    @record = record
    if record.perform_validation?
      fields = self.class.class_variable_get("@@#{self.class.to_s.underscore}_fields".to_sym)
      fields.each do |field|
        self.send("validate_#{field}")
      end
    end
  end


  private

  def validate_presence(attribute, message)
    add_error(attribute, message) if @record.send(attribute).blank?
  end

  def add_error(attribute, message)
    @record.errors[attribute] << message
  end


end