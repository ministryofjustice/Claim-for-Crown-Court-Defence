module ADP
  module API
    module Advocates
      class V1 < Grape::API

      version 'v1', using: :header, vendor: 'Advocate Defence Payments'
      format :json
      prefix 'api/advocates'
      content_type :json, 'application/json'

      resource :claims do
        desc "Create a claim."

        params do
          requires :advocate_id, type: String, desc: "Your unique identifier as an adavocate."
        end

        post do
          Claim.create!({
            advocate_id: params[:advocate_id]
          })
        end
      end

      add_swagger_documentation
      end
    end
  end
end
