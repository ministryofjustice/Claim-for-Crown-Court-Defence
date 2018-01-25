module CCLF
  module Fee
    class FixedFeeAdapter < BaseFeeAdapter
      FIXED_FEE_BILL_MAPPINGS = {
        FXACV: zip(%w[LIT_FEE LIT_FEE ST1TS0T5]), # Appeal against conviction
        FXASE: zip(%w[LIT_FEE LIT_FEE ST1TS0T6]), # Appeal against sentence
        FXCBR: zip(%w[LIT_FEE LIT_FEE ST3TS3TB]), # Breach of Crown Court order
        FXCSE: zip(%w[LIT_FEE LIT_FEE ST1TS0T7]), # Committal for Sentence
        FXCON: zip(%w[LIT_FEE LIT_FEE ST1TS0T8]), # Contempt
        FXENP: zip(%w[LIT_FEE LIT_FEE ST4TS0T1]), # Elected cases not proceeded *
        FXH2S: zip(%w[LIT_FEE LIT_FEE ST1TS0TC]), # Hearing subsequent to sentence
      }.freeze
      # * "final" claim "elected case not proceeded" only
      # TODO: ST4TS0T2 to 7 are transfer claims "elected case not proceeded" for new and orginal

      def claimed?
        maps?
      end

      private

      def bill_mappings
        FIXED_FEE_BILL_MAPPINGS
      end

      def bill_key
        object.fee_type.unique_code.to_sym
      end
    end
  end
end
