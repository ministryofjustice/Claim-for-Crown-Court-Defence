module CCLF
  module Fee
    class FixedFeeAdapter < BaseFeeAdapter
      # TODO: unneeded as are all the same
      FIXED_FEE_BILL_MAPPINGS = {
        FXACV: zip(%w[LIT_FEE LIT_FEE]), # Appeal against conviction
        FXASE: zip(%w[LIT_FEE LIT_FEE]), # Appeal against sentence
        FXCBR: zip(%w[LIT_FEE LIT_FEE]), # Breach of Crown Court order
        FXCSE: zip(%w[LIT_FEE LIT_FEE]), # Committal for Sentence
        FXCON: zip(%w[LIT_FEE LIT_FEE]), # Contempt
        FXENP: zip(%w[LIT_FEE LIT_FEE]), # Elected cases not proceeded *
        FXH2S: zip(%w[LIT_FEE LIT_FEE]), # Hearing subsequent to sentence
      }.freeze

      def claimed?
        maps? & charges?
      end

      private

      def bill_mappings
        FIXED_FEE_BILL_MAPPINGS
      end

      def bill_key
        object.fee_type.unique_code.to_sym
      end

      def charges?
        object.amount&.positive?
      end
    end
  end
end
