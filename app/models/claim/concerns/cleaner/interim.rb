module Claim
  class Cleaner
    class Interim < Cleaner
      private

      def destroy_invalid_disbursements
        return unless interim_fee&.is_interim_warrant?

        disbursements.destroy_all
        claim.disbursements = []
      end
    end
  end
end
