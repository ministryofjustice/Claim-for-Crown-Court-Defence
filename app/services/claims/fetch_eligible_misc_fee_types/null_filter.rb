module Claims
  class FetchEligibleMiscFeeTypes
    class NullFilter
      def initialize; end

      def call
        []
      end
    end
  end
end
