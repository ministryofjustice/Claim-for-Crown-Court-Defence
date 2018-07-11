# Service to calculate the unit price for a given fee.
# Unit price will require input from different attributes
# on the claim and may require input from different CCCD fees
# to be consolidated/munged.
#
module Claims
  module FeeCalculator
    # TODO: this is simply using calculate endpoint with quantity of 1
    # to get the unit price, but could use the prices endpoint
    # directly - amend laa-fee-calculator-client gem to add it.
    #
    class UnitPrice < Calculate
      def initialize(claim, options)
        super
        @options = options.merge(quantity: 1)
      end
    end
  end
end
