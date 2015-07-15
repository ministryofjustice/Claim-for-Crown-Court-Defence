module ADP
  module API
    module Advocates
      class V1 < Grape::API

      version 'v1', using: :header, vendor: 'Advocate Defence Payments'
      format :json
      prefix 'api/advocates'
      content_type :json, 'application/json'

      resource :claims do

        helpers do
          params :claim_creation do
            requires :advocate_id, type: Integer, desc: "Your unique identifier as an adavocate."
            requires :creator_id, type: Integer, desc: "Your unique identifier as a creator of the claim."
            requires :case_number, type: String, desc: "The case number"
            requires :case_type, type: String, desc: "The case type i.e trial"
            optional :cms_number, type: String, desc: "The CMS number"
          end

          def args
            {
              advocate_id: params[:advocate_id],
              creator_id: params[:creator_id],
              case_number: params[:case_number],
              case_type: params[:case_type],
              cms_number: params[:cms_number]
            }
          end

        end

        desc "Create a claim."

        params do
          use :claim_creation
        end

        post do
          Claim.create!(args)
        end

        desc "Validate a claim."

        params do
          use :claim_creation
        end

        post '/validate' do
          Claim.new(args).valid?
        end

      end

      add_swagger_documentation
      end
    end
  end
end
