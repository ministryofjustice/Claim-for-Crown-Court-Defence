module Claims
  class FetchEligibleMiscFeeTypes
    class Agfs < Base
      private

      def apply_filter?
        apply_trial_fee_filter?
      end

      def fee_types_by_claim_type
        return scheme_scope.supplementary if claim.supplementary?
        scheme_scope.without_supplementary_only
      end

      def scheme_scope
        return Fee::MiscFeeType.agfs_scheme_12s if agfs_scheme_12?
        return Fee::MiscFeeType.agfs_scheme_10s if agfs_reform?
        Fee::MiscFeeType.agfs_scheme_9s
      end
    end
  end
end
