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
    class BasicFeeAdapter < SimpleBillAdapter
      acts_as_simple_bill bill_type: 'AGFS_FEE', bill_subtype: 'AGFS_FEE'

      def claimed?
        filtered_fees.any? do |f|
          f.amount&.positive? || f.quantity&.positive? || f.rate&.positive?
        end
      end

      private

      def fee_types
        %w[BABAF BADAF BADAH BADAJ BANOC BANDR BANPW BAPPE]
      end

      def filtered_fees
        fees.select do |f|
          fee_types.include?(f.fee_type.unique_code)
        end
      end
    end
  end
end
