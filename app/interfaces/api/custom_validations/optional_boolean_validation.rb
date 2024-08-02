module API
  module CustomValidations
    class OptionalBooleanValidation < Grape::Validations::Validators::Base
      def validate_param!(attr_name, params)
        london_rates_apply = params[attr_name]

        raise ArgumentError unless london_rates_apply.nil? || london_rates_apply.in?([true, false])
      rescue ArgumentError
        raise Grape::Exceptions::Validation.new(params: [@scope.full_name(attr_name)],
                                                message: 'must be true, false or nil')
      end
    end
  end
end
