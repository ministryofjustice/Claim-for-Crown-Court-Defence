module CCLF
  module Fee
    class GraduatedFeeAdapter < BaseFeeAdapter
      # TODO: unneeded as are all the same
      GRADUATED_FEE_BILL_MAPPINGS = {
        GRDIS: zip(%w[LIT_FEE LIT_FEE]), # Discontinuance CCLFscenario "guilty plea, discontinuance (pre PCMH)"
        GRGLT: zip(%w[LIT_FEE LIT_FEE]), # Guilty plea. CCLF scenario "guilty plea, guilty plea"
        GRTRL: zip(%w[LIT_FEE LIT_FEE]), # Trial **
        GRRTR: zip(%w[LIT_FEE LIT_FEE]), # Retrial **
        GRRAK: zip(%w[LIT_FEE LIT_FEE]), # Cracked trial **
        GRCBR: zip(%w[LIT_FEE LIT_FEE]), # Cracked before retrial **
      }.freeze

      # **
      # NOTE: in CCLF these scenarios are for a "final" trial/retrial/cracked trial/cracked before retrial
      #   - there are many other scenarios covering interim and transfer claim varieties

      def claimed?
        maps? & charges?
      end

      private

      def bill_mappings
        GRADUATED_FEE_BILL_MAPPINGS
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
