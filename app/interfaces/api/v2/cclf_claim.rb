module API
  module V2
    class CCLFClaim < Grape::API
      helpers ClaimParamsHelper

      helpers do
        def claim
          ::Claim::BaseClaim.lgfs.find_by(uuid: params[:uuid]) || error!('Claim not found', 404)
        end

        def entity_class
          if claim.interim?
            API::Entities::CCLF::InterimClaim
          elsif claim.transfer?
            API::Entities::CCLF::TransferClaim
          else
            API::Entities::CCLF::FinalClaim
          end
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
