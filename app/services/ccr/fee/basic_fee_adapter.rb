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
# The "Advocate Fee, advocate fee" is the CCR equivalent of most but not
#  all the BasicFeeType fees in CCCD. It is of type
#  AGFS_FEE and subtype AGFS_FEE in CCR.
#
#  NOTE: see fixed fee adapter for more on the "Advocate Fee, advocate fee" mappings
#        relating to fixed fees.
#
#   * This fee can be derived from CCCD fees of the following types:
#     BABAF BADAF BADAH BADAJ BANOC BANDR BANPW BAPPE
#
#  * The BASAF, BAPCM and BACAV fees are handled
#    as miscellaneous fees in CCR (i.e. AGFS_MISC_FEES).
#
module CCR
  module Fee
    class BasicFeeAdapter < BaseFeeAdapter
      BASIC_FEE_BILL_MAPPINGS = {
        GRRAK: zip(%w[AGFS_FEE AGFS_FEE]), # Cracked Trial - LGFS only
        GRCBR: zip(%w[AGFS_FEE AGFS_FEE]), # Cracked before retrial - LGFS only
        GRDIS: zip(%w[AGFS_FEE AGFS_FEE]), # Discontinuance
        GRGLT: zip(%w[AGFS_FEE AGFS_FEE]), # Guilty plea
        GRRTR: zip(%w[AGFS_FEE AGFS_FEE]), # Retrial
        GRTRL: zip(%w[AGFS_FEE AGFS_FEE]) # Trial
      }.freeze

      def claimed?
        maps? && charges?
      end

      private

      def bill_mappings
        BASIC_FEE_BILL_MAPPINGS
      end

      def bill_key
        object.case_type.fee_type_code.to_sym
      end

      def fee_types
        %w[BABAF BADAF BADAH BADAJ BANOC BANDR BANPW BAPPE]
      end

      def fees
        object.fees.select do |f|
          fee_types.include?(f.fee_type.unique_code)
        end
      end

      def charges?
        fees.any? do |f|
          f.amount.positive? || f.quantity.positive? || f.rate.positive?
        end
      end
    end
  end
end
