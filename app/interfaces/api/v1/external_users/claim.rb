module API
  module V1
    module ExternalUsers
      class Claim < Grape::API
        resource :claims, desc: 'Create or Validate' do
          before_validation do
            authorise_claim!
          end

          mount API::V1::ExternalUsers::Claims::AdvocateClaim
          mount API::V1::ExternalUsers::Claims::FinalClaim
          mount API::V1::ExternalUsers::Claims::InterimClaim
          mount API::V1::ExternalUsers::Claims::TransferClaim
        end
      end
    end
  end
end
