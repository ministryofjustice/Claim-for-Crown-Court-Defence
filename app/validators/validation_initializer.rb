class ValidationInitializer < ActiveModel::Validator

  def validate(record)
    record.errors.clear
  end


end