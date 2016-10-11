module API
  module V2
    class Claim < Grape::API
      content_type :xml, 'application/xml'
      formatter :xml, API::Helpers::XMLFormatter

      helpers do
        def claim
          ::Claim::BaseClaim.find_by(uuid: params.uuid) || error!('Claim not found', 404)
        end
      end

      resource :claims, desc: 'Operations on claims' do
        route_param :uuid do
          desc 'Retrieve a claim by UUID'
          params do
            optional :api_key, type: String, desc: 'REQUIRED: The API authentication key of the user'
            requires :uuid, type: String, desc: 'REQUIRED: Claim UUID'
          end
          get do
            present claim, with: API::Entities::FullClaim, root: 'claim', user: current_user
          end
        end
      end
    end
  end
end
