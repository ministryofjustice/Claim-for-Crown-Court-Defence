module ExternalUsers
  module Litigators
    class HardshipClaimsController < ExternalUsers::ClaimsController
      skip_load_and_authorize_resource

      resource_klass Claim::LitigatorHardshipClaim

      private

      def build_nested_resources
        @case_stages = @claim.eligible_case_stages.chronological
        @claim.build_hardship_fee if @claim.hardship_fee.nil?

        # TODO: TBC what fees, expense and disbursements are available
        %i[misc_fees disbursements expenses].each do |association|
          build_nested_resource(@claim, association)
        end

        super
      end
    end
  end
end
