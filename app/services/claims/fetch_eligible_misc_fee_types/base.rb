module Claims
  class FetchEligibleMiscFeeTypes
    class Base
      def initialize(claim)
        @claim = claim
      end

      def call
        filter_trial_only_types(fee_types_by_claim_type, apply_filter?)
      end

      private

      attr_reader :claim
      delegate :case_type, :agfs?, :lgfs?, :agfs_reform?, :agfs_scheme_12?, :hardship?, to: :claim, allow_nil: true

      def apply_trial_fee_filter?
        !case_type&.is_trial_fee? && case_type
      end

      def apply_clar_rep_order_filter?
        claim&.earliest_representation_order_date &&
          (claim.earliest_representation_order_date < Settings.clar_release_date.to_date.beginning_of_day)
      end

      def apply_transfer_guilty_plea_filter?
        claim.transfer? && claim.transfer_detail.case_conclusion_id &&
          Claim::TransferBrain.case_conclusion_by_id(claim.transfer_detail.case_conclusion_id) == 'Guilty plea'
      end

      def filter_trial_only_types(relation, filter)
        filter ? relation.without_trial_fee_only : relation
      end
    end
  end
end
