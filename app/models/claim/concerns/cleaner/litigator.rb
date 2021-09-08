module Claim
  class Cleaner
    class Litigator < Cleaner
      private

      def destroy_invalid_fees
        return if case_type.blank?

        if case_type.is_fixed_fee?
          graduated_fee&.destroy
          claim.graduated_fee = nil
        else
          fixed_fee&.destroy
          claim.fixed_fee = nil
        end
      end
    end
  end
end
