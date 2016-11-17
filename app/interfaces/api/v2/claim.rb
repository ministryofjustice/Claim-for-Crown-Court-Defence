module API
  module V2
    class Claim < Grape::API
      content_type :soap, 'text/plain'
      content_type :xml, 'application/xml'
      formatter :xml, API::Helpers::XMLFormatter

      helpers do
        def claim
          ::Claim::BaseClaim.find_by(uuid: params.uuid) || error!('Claim not found', 404)
        end

        def soap_format?
          request.env['api.format'] == :soap
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
            if soap_format?
              body Messaging::ExportRequest.new(claim).to_xml
            else
              present claim, with: API::Entities::FullClaim, root: 'claim'
            end
          end
        end
      end
    end
  end
end
