module CCLF
  module Fee
    class InterimFeeAdapter < MappingBillAdapter
      # NOTE: "Disbursement only" (INDIS) fee is not inluded as it
      # just a switch to indicate only disbursements should exist
      INTERIM_FEE_BILL_MAPPINGS = {
        INPCM: zip(%w[LIT_FEE LIT_FEE]), # Effective PCMH
        INRNS: zip(%w[LIT_FEE LIT_FEE]), # Retrial New solicitor
        INRST: zip(%w[LIT_FEE LIT_FEE]), # Retrial start
        INTDT: zip(%w[LIT_FEE LIT_FEE]), # Trial start
        INWAR: zip(%w[FEE_ADVANCE WARRANT]) # Warrant
      }.freeze

      private

      def bill_mappings
        INTERIM_FEE_BILL_MAPPINGS
      end

      def bill_key
        object.fee_type.unique_code.to_sym
      end
    end
  end
end
