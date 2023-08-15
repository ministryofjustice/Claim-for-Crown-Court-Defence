module ExternalUsers
  module Advocates
    class HardshipClaimsController < ExternalUsers::ClaimsController
      skip_load_and_authorize_resource

      resource_klass Claim::AdvocateHardshipClaim

      private

      def build_nested_resources
        @case_stages = @claim.eligible_case_stages.chronological

        %i[misc_fees expenses].each do |association|
          build_nested_resource(@claim, association)
        end

        super
      end
    end
  end
end
