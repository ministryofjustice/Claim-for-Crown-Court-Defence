# Describes the unit value limit range for given a fee type
#
# NOTE: these limits represent the minimum
# needed to get a single price for a
# given fee type, to then use as a "rate".
# However, there are other prices for a given fee
# type with different limits that represent the
# "graduated" increase/decrease in price for given
# fee type.
# e.g. a BASAF (standard appearance fee) has
#      one price "per day" when claiming between 5 and 30 days
#      but a different price "per day" thereafter
#
# TODO: additional limits for a given fee type are
# not handled as they break the quantity * rate
# simplistic multiplication that CCCD applies via
# the interface. This needs a fundamental change
# to the interface and service logic.
#
module Claims
  module FeeCalculator
    class FeeTypeLimit
      SCHEME_9_FEE_TYPE_LIMIT_MAPPINGS = {
        BABAF: { from: 1, to: 2 },
        BADAF: { from: 3, to: 40 },
        BADAH: { from: 41, to: 50 },
        BADAJ: { from: 51, to: 9999 },
        BASAF: { from: 5, to: 30 },
        BAPCM: { from: 6, to: nil },
        BACAV: { from: 7, to: 8 }
      }.with_indifferent_access.freeze

      AGFS_REFORM_FEE_TYPE_LIMIT_MAPPINGS = {
        BABAF: { from: 1, to: 1 },
        BADAT: { from: 2, to: 9999 },
        BASAF: { from: 1, to: 6 },
        BAPCM: { from: 1, to: 6 },
        BACAV: { from: 7, to: 8 }
      }.with_indifferent_access.freeze

      def initialize(fee_type, claim)
        @fee_type = fee_type
        @claim = claim
      end

      attr_reader :fee_type, :claim

      def limit_from
        scheme_mappings.fetch(fee_type_unique_code, nil)&.fetch(:from) || default_limit_from
      end

      def limit_to
        scheme_mappings.fetch(fee_type_unique_code, nil)&.fetch(:to)
      end

      private

      delegate :agfs?, :fee_scheme, to: :claim

      def fee_type_unique_code
        fee_type&.unique_code&.to_s
      end

      def default_limit_from
        agfs? ? 1 : 0
      end

      def scheme_mappings
        return {} unless agfs?
        fee_scheme.agfs_reform? ? AGFS_REFORM_FEE_TYPE_LIMIT_MAPPINGS : SCHEME_9_FEE_TYPE_LIMIT_MAPPINGS
      end
    end
  end
end
