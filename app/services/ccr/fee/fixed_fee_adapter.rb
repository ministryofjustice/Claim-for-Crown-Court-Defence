# CCR bill types are logically similar to CCCD fee types,
# however the "advocate fee" maps to both
# CCCD basic fees and CCCD fixed fees, based on its subtype
# AND/OR bill scenario.
#

# The "Advocate Fee" has five sub types in CCR
#  1. The "advocate fee" (yes, same name) - AGFS_FEE, AGFS_FEE
#      --> either various basic fees in CCCD or various fixed fees for "Elected case not proceeded"
#  2. "Appeal against conviciton" - AGFS_FEE AGFS_APPEAL_CON --> a fixed fee in CCCD
#  3. "Appeal against sentence"- AGFS_FEE AGFS_APPEAL_SEN --> a fixed fee in CCCD
#  4. "Breach of crown court order"- AGFS_FEE AGFS_ORDER_BRCH --> a fixed fee in CCCD
#  5. "Commital for sentence"- AGFS_FEE AGFS_FEE AGFS_COMMITTAL --> a fixed fee in CCCD
#
# A. For CCCD fixed fees the "Advocate Fee, advocate fee" is the CCR equivalent of, at least,
#     the "Elected case not proceeded" fees. It is of type AGFS_FEE and subtype AGFS_FEE in CCR.
#
#  NOTE: see basic fee adapter for more on the "Advocate Fee, advocate fee" mappings
#        relating to basic fees.
#
# B. For other CCCD fixed fees the bill sub type is based on the case_type/bill_scenario
#
#   * The fee's attributes can be derived from CCCD fees equivalent to the
#     case_type/bill_scenario plus uplift versions and generic fixed
#     case/defendant uplift fees. see adapted fixed fee entity for specifics.
#     e.g.  FXACV FXASE FXCBR FXCSE FXENP
#             plus their uplifts...
#           FXACU FXASU FXCBU FXCSU FXENU
#             plus general fixed case uplifts...
#           FXNOC
#             plus general fixed defendant uplifts...
#           FXNDR
#
# C. Yet other CCCD fixed fees actually map to miscellaneous fees in CCR
#     i.e. FXCON, FXSAF (contempt and standard appearance fee respectively)
#
module CCR
  module Fee
    class FixedFeeAdapter < BaseFeeAdapter
      FIXED_FEE_BILL_MAPPINGS = {
        FXACV: zip(%w[AGFS_FEE AGFS_APPEAL_CON]), # Appeal against conviction
        FXASE: zip(%w[AGFS_FEE AGFS_APPEAL_SEN]), # Appeal against sentence
        FXCBR: zip(%w[AGFS_FEE AGFS_ORDER_BRCH]), # Breach of Crown Court order
        FXCSE: zip(%w[AGFS_FEE AGFS_COMMITTAL]), # Committal for Sentence
        FXENP: zip(%w[AGFS_FEE AGFS_FEE]), # Elected cases not proceeded
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

      def fee_types
        bill_mappings.keys.map(&:to_s)
      end

      # if the claim maps as a fixed fee (based on case type) then we can assume
      # they are claiming the matching fixed fee, regardless.
      # NOTE: this logic is to be applied in the app too eventually
      def charges?
        true
      end
    end
  end
end
