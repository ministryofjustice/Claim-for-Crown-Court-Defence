module API
  module V1
    module ExternalUsers
      class Claim < Grape::API
        version 'v1', using: :header, vendor: 'Advocate Defence Payments'
        format :json
        prefix 'api/external_users'
        content_type :json, 'application/json'

        resource :claims, desc: 'Create or Validate' do
          before do
            authorise_claim!
          end

          mount API::V1::ExternalUsers::Claims::AdvocateClaim

          # TODO: uncomment to enable the new types
          #mount API::V1::ExternalUsers::Claims::FinalClaim
          #mount API::V1::ExternalUsers::Claims::InterimClaim
          #mount API::V1::ExternalUsers::Claims::TransferClaim
        end
      end
    end
  end
end
