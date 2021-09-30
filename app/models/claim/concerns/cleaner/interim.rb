module Claim
  class Cleaner
    class Interim < Cleaner
      attr_accessor :claim

      delegate_missing_to :claim

      def initialize(claim)
        @claim = claim
      end

      def call
        destroy_all_invalid_fee_types
      end

      private

      def destroy_all_invalid_fee_types
        return unless interim_fee&.is_interim_warrant?

        disbursements.destroy_all
        claim.disbursements = []
      end
    end
  end
end
