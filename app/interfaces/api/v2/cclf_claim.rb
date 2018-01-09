module API
  module V2
    class CCLFClaim < Grape::API
      helpers ClaimParamsHelper

      helpers do
        def claim
          ::Claim::BaseClaim.lgfs.find_by(uuid: params.uuid) || error!('Claim not found', 404)
        end
      end

      resource :claims, desc: 'Operations on claims' do
        desc 'Retrieve a claim by UUID for CCLF injection'
        params { use :common_injection_params }

        get ':uuid' do
          present claim, with: entity_class
        end
      end
    end
  end
end
