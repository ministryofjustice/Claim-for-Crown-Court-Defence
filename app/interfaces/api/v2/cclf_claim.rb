module API
  module V2
    class CCLFClaim < Grape::API
      helpers do
        def claim
          # TODO: need to check InterimClaim and TransferClaim too
          ::Claim::LitigatorClaim.find_by(uuid: params.uuid) || error!('Claim not found', 404)
        end
      end

      resource :claims, desc: 'Operations on claims' do
        route_param :uuid do
          desc 'Retrieve a claim in CCLF format by UUID'

          params do
            optional :api_key, type: String, desc: 'REQUIRED: The API authentication key of the user'
            requires :uuid, type: String, desc: 'REQUIRED: Claim UUID'
          end

          get do
            present claim, with: API::Entities::CCLFClaim
          end
        end
      end
    end
  end
end
