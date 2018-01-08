module API
  module V2
    class CCRClaim < Grape::API
      helpers ClaimParamsHelper

      helpers do
        def claim
          ::Claim::AdvocateClaim.find_by(uuid: params.uuid) || error!('Claim not found', 404)
        end
      end

      resource :claims, desc: 'Operations on claims' do
        route_param :uuid do
          desc 'Retrieve a claim by UUID for CCR injection'

          params { use :common_injection_params }

          get do
            present claim, with: API::Entities::CCRClaim
          end
        end
      end
    end
  end
end
