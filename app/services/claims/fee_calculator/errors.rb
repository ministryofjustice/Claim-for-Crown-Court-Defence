module Claims
  module FeeCalculator
    class PriceError < RuntimeError; end

    class ExclusionException < PriceError
      def initialize(msg = nil)
        @message = msg
      end

      def message
        "price calculation excluded: #{@message + ' ' if @message}"
      end
    end

    class InterimWarrantExclusion < ExclusionException
      def message
        super + 'cannot determine warrant prices without more details'
      end
    end

    class RetrialReductionExclusion < ExclusionException
      def message
        super + 'cannot determine retrial prices where retrial started before trial concluded'
      end
    end

    class CrackedBeforeRetrialExclusion < ExclusionException
      def message
        super + 'cannot determine cracked before retrial prices without more details'
      end
    end
  end
end
