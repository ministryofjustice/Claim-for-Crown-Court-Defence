module ADP
  module API
    module Advocates
      class V1 < Grape::API

      version 'v1', using: :header, vendor: 'Advocate Defence Payments'
      format :json
      prefix 'api/advocates'

      resource :claims do
        desc "Create a claim."

        params do
          requires :email, type: String, desc: "Your email."
        end

        post do
          Claim.create!({
            email: params[:email]
          })
        end
      end

      add_swagger_documentation
      end
    end
  end
end
