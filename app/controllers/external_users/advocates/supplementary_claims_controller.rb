module ExternalUsers
  module Advocates
    class SupplementaryClaimsController < ExternalUsers::ClaimsController
      skip_load_and_authorize_resource

      resource_klass Claim::AdvocateSupplementaryClaim

      def build_nested_resources
        build_misc_fees

        %i[expenses].each do |association|
          build_nested_resource(@claim, association)
        end

        super
      end

      def build_misc_fees
        existing_misc_fee_fee_type_ids = @claim.misc_fees.map(&:fee_type_id)

        @claim.eligible_misc_fee_types.each do |eligible_fee_type|
          next if existing_misc_fee_fee_type_ids.include?(eligible_fee_type.id)
          @claim.misc_fees.build(fee_type_id: eligible_fee_type.id)
        end
      end
    end
  end
end
