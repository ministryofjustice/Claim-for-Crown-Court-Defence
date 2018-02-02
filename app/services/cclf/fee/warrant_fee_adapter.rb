module CCLF
  module Fee
    class WarrantFeeAdapter < SimpleBillAdapter
      def bill_type
        'FEE_ADVANCE'
      end

      def bill_subtype
        'WARRANT'
      end
    end
  end
end
