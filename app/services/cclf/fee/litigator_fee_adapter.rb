module CCLF
  module Fee
    class LitigatorFeeAdapter < SimpleFeeAdapter
      def bill_type
        'LIT_FEE'
      end

      def bill_subtype
        'LIT_FEE'
      end
    end
  end
end
