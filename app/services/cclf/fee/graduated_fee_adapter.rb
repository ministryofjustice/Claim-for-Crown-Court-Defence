module CCLF
  module Fee
    class GraduatedFeeAdapter < BaseFeeAdapter
      GRADUATED_FEE_BILL_MAPPINGS = {
        GRDIS: zip(%w[LIT_FEE LIT_FEE ST1TS0T1]), # Discontinuance CCLFscenario "guilty plea, discontinuance (pre PCMH)"
        GRGLT: zip(%w[LIT_FEE LIT_FEE ST1TS0T2]), # Guilty plea. CCLF scenario "guilty plea, guilty plea"
        GRTRL: zip(%w[LIT_FEE LIT_FEE ST1TS0T4]), # Trial **
        GRRTR: zip(%w[LIT_FEE LIT_FEE ST1TS0TA]), # Retrial **
        GRRAK: zip(%w[LIT_FEE LIT_FEE ST1TS0T3]), # Cracked trial **
        GRCBR: zip(%w[LIT_FEE LIT_FEE ST1TS0T9]), # Cracked before retrial **
      }.freeze

      # **
      # NOTE: in CCLF these scenarios are for a "final" trial/retrial/cracked trial/cracked before retrial
      #   - there are many other scenarios covering interim and transfer claim varieties

      def claimed?
        maps?
      end

      private

      def bill_mappings
        GRADUATED_FEE_BILL_MAPPINGS
      end

      def bill_key
        object.case_type.fee_type_code.to_sym
      end
    end
  end
end
