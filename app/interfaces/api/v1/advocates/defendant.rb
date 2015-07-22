module API
  module V1

    
    class Error < StandardError; end
    class ArgumentError < Error; end

    module Advocates

      class Defendant < Grape::API

        version 'v1', using: :header, vendor: 'Advocate Defence Payments'
        format :json
        prefix 'api/advocates'
        content_type :json, 'application/json'

        resource :defendants do

          helpers do
            params :defendant_creation do
              requires :claim_id, type: Integer, desc: "Unique identifier for the claim associated with this defendant."
              requires :first_name, type: String, desc: "First name of the defedant."
              requires :last_name, type: String, desc: "Last name of the defendant."
              requires :date_of_birth, type: DateTime, desc: "Defendant's date of birth."
            end

            def args
              {
                claim_id: params[:claim_id],
                first_name: params[:first_name],
                last_name: params[:last_name],
                date_of_birth: params[:date_of_birth]
              }
            end

          end

          desc "Create a defendant."

          params do
            use :defendant_creation
          end

          post do
            ::Defendant.create!(args)
          end

        end

        add_swagger_documentation hide_documentation_path: true

      end

    end

  end
end