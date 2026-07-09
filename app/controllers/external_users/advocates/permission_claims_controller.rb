module ExternalUsers
  module Advocates
    class PermissionClaimsController < ExternalUsers::ClaimsController
      skip_load_and_authorize_resource

      resource_klass Claim::AdvocatePermissionClaim

      private

      def build_nested_resources
        %i[misc_fees expenses].each do |association|
          build_nested_resource(@claim, association)
        end

        super
      end
    end
  end
end
