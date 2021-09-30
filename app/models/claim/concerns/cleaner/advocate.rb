module Claim
  class Cleaner
    class Advocate < Cleaner
      private

      def destroy_invalid_fees
        if case_type.present? && case_type.is_fixed_fee?
          clear_basic_fees
          destroy_ineligible_fixed_fees
        else
          fixed_fees.destroy_all unless fixed_fees.empty?
        end
      end

      def clear_basic_fees
        basic_fees.map(&:clear) unless basic_fees.empty?
      end

      # TODO: looping over a collection and deleting from it impacts the looping.
      # change to collect the ineligble in loop and THEN delete. see misc fee cleaner
      def destroy_ineligible_fixed_fees
        eligbile_fees = Claims::FetchEligibleFixedFeeTypes.new(self).call
        fixed_fees.each do |fee|
          fixed_fees.delete(fee) unless eligbile_fees.map(&:code).include?(fee.fee_type_code)
        end
      end

      def clear_inapplicable_fields
        clear_cracked_details if case_type.present? && !requires_cracked_dates?
      end

      def clear_cracked_details
        claim.trial_fixed_notice_at = nil if trial_fixed_notice_at
        claim.trial_fixed_at = nil if trial_fixed_at
        claim.trial_cracked_at = nil if trial_cracked_at
        claim.trial_cracked_at_third = nil if trial_cracked_at_third
      end
    end
  end
end
