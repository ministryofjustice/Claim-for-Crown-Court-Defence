module API
  module V2
    class CCRClaim < Grape::API
      helpers do
        def claim
          ::Claim::AdvocateClaim.find_by(uuid: params.uuid) || error!('Claim not found', 404)
        end
      end

      resource :claims, desc: 'Operations on claims' do
        route_param :uuid do
          desc 'Retrieve a claim in CCR format by UUID'

          params do
            optional :api_key, type: String, desc: 'REQUIRED: The API authentication key of the user'
            requires :uuid, type: String, desc: 'REQUIRED: Claim UUID'
          end

          get do
            present claim, with: API::Entities::CCRClaim
          end
        end
      end
    end
  end
end
