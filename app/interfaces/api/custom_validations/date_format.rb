class StandardJsonFormat < Grape::Validations::Base
  # ISO 8601 format
  #
  # Valid examples:
  #
  #   2016-12-01
  #   2016-12-01T00:00:00
  #   2016-12-01T00:00:00Z
  #   2016-12-01T19:20+01:00
  #
  # Invalid examples:
  #
  #   2016
  #   2016-12
  #   2016-14-01
  #   2016-12-01Z
  #
  def validate_param!(attr_name, params)
    date_str = params[attr_name]

    date_str =~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}(.*)?$/ || (raise ArgumentError)
    Date.iso8601(date_str) # if date is not valid iso8601 it will raise an ArgumentError
  rescue ArgumentError
    raise Grape::Exceptions::Validation,
          params: [@scope.full_name(attr_name)],
          message: 'is not in an acceptable date format (YYYY-MM-DD[T00:00:00])'
  end
end
