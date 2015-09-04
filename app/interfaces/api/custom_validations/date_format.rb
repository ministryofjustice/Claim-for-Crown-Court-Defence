class StandardJsonFormat < Grape::Validations::Base
  def validate_param!(attr_name, params)
    unless params[attr_name] =~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/
      fail Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: "is not in standard JSON date format (YYYY-MM-DD)"
    end
  end
end