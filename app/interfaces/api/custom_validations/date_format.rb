class StandardJsonFormat < Grape::Validations::Base
  def validate_param!(attr_name, params)

    #
    # regex pattern: "sortable" e.g.
    #   match     - 2015-05-21
    #   match     - 2015-05-21T14:00:00
    #
    unless params[attr_name] =~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}:[0-9]{2})?$/
      fail Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: "is not in an acceptable date format (YYYY-MM-DD[T00:00:00])"
    end
  end
end
