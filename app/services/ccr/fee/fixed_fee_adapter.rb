# CCR bill types are logically similar to CCCD fee types,
# however the "advocate fee" is a combination
# of some of the basic fee types' values.

# The "Advocate Fee" has five sub types in CCR
#  1. The "advocate fee" (yes, same name) - AGFS_FEE, AGFS_FEE --> various basic fees in CCCD
#  2. "Appeal against conviciton" - AGFS_FEE AGFS_APPEAL_CON --> a fixed fee in CCCD
#  3. "Appeal against sentence"- AGFS_FEE AGFS_APPEAL_SEN --> a fixed fee in CCCD
#  4. "Breach of crown court order"- AGFS_FEE AGFS_ORDER_BRCH --> a fixed fee in CCCD
#  5. "Commital for sentence"- AGFS_FEE AGFS_FEE AGFS_COMMITTAL --> a fixed fee in CCCD
#
# A. The "Advocate Fee, advocate fee" is the CCR equivalent of most but not
#  all the BasicFeeType fees in CCCD. It is of type
#  AGFS_FEE and subtype AGFS_FEE in CCR.
#
#   * This fee can be derived from CCCD fees of the following types:
#     BABAF BADAF BADAH BADAJ BANOC BANDR BANPW BAPPE
#
#  * In addition the BANDR (defendant uplifts) is
#    being mappd based on the actual number of defendants
#    at time of writing (and ignoring the quantity of this fee??!)
#
#  * The BASAF, BAPCM and BACAV fees are handled
#    as miscellaneous fees in CCR (i.e. AGFS_MISC_FEES).
#
# INJECTION: eventually the bill type and sub type (for advocate fee)
# should be derivable by CCR from the bill scenario alone, since this
# maps the case type in any event.
#
module CCR
  module Fee
    class FixedFeeAdapter < BaseFeeAdapter
      # The CCR "Advocate fee" bill can have different sub types
      # based on the type of case, which map as follows.
      # Those case types with nil values cannot claim an "Advocate fee" at all
      #
      FIXED_FEE_BILL_MAPPINGS = {
        FXACV: zip(%w[AGFS_FEE AGFS_APPEAL_CON]), # Appeal against conviction
        FXASE: zip(%w[AGFS_FEE AGFS_APPEAL_SEN]), # Appeal against sentence
        FXCBR: zip(%w[AGFS_FEE AGFS_ORDER_BRCH]), # Breach of Crown Court order
        FXCSE: zip(%w[AGFS_FEE AGFS_COMMITTAL]), # Committal for Sentence
        FXCON: zip([nil, nil]), # Contempt
        FXENP: zip([nil, nil]), # Elected cases not proceeded - this is a bill scenario in CCR
        FXH2S: zip([nil, nil]), # Hearing subsequent to sentence - LGFS only
      }.freeze

      def claimed?
        maps? && charges?
      end

      private

      def bill_mappings
        FIXED_FEE_BILL_MAPPINGS
      end

      def bill_key
        object.case_type.fee_type_code.to_sym
      end

      def charges?
        object.fixed_fees.any? do |f|
          f.amount.positive? || f.quantity.positive? || f.rate.positive?
        end
      end
    end
  end
end
