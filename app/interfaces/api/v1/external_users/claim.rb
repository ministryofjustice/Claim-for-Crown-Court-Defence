module API
  module V1
    module ExternalUsers
      class Claim < Grape::API
        resource :claims, desc: 'Create or Validate' do
          before_validation do
            authorise_claim!
          end

          mount API::V1::ExternalUsers::Claims::AdvocateClaim # deprecated advocate "final" claim endpoint
          mount API::V1::ExternalUsers::Claims::Advocates::FinalClaim
          mount API::V1::ExternalUsers::Claims::Advocates::InterimClaim
          mount API::V1::ExternalUsers::Claims::Advocates::SupplementaryClaim
          mount API::V1::ExternalUsers::Claims::FinalClaim
          mount API::V1::ExternalUsers::Claims::InterimClaim
          mount API::V1::ExternalUsers::Claims::TransferClaim
          mount API::V1::ExternalUsers::Claims::Litigators::HardshipClaim
        end
      end
    end
  end
end
