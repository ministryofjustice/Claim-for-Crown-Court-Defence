module Claims
  module FeeCalculator
    class NullPrice
      def initialize(*args); end

      # Returns Json response indicating an error has occurred.
      def call
        Response.new(success?: false,
                     data: nil,
                     errors: ['Incorrect Price Type'],
                     message: I18n.t('fee_calculator.calculate.amount_unavailable'))
      end
    end
  end
end
