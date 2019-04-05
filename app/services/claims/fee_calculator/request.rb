# Price: Wraps a fee calc API request
# to handle structuring the response.
# `#call` will always return a response
#
module Claims
  module FeeCalculator
    class Request
      attr_reader :service

      Data = Struct.new(:amount, :unit, keyword_init: true)

      def initialize(service)
        @service = service
      end

      def call
        response(true, data)
      rescue StandardError => e
        Rails.logger.error("error: #{e.message}")
        response(false, nil, [e.message], I18n.t('fee_calculator.calculate.amount_unavailable'))
      end

      private

      def response(success, data = nil, errors = nil, message = nil)
        Response.new(success?: success, data: data, errors: errors, message: message)
      end

      def amount
        @amount ||= service.send(:amount)
      end

      def data
        @data ||= case amount
                  when Price
                    Data.new(amount: amount.per_unit, unit: amount.unit)
                  else
                    Data.new(amount: amount)
                  end
      end
    end
  end
end
