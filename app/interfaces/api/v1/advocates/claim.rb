module API
  module V1

    # ceate our own rescuable namespaced errors
    class Error < StandardError; end
    class ArgumentError < Error; end

    module Advocates
      
      class Claim < Grape::API

        version 'v1', using: :header, vendor: 'Advocate Defence Payments'
        format :json
        prefix 'api/advocates'
        content_type :json, 'application/json'

      resource :claims do

        helpers do
          params :claim_creation do
            requires :advocate_email, type: String, desc: "Your ADP account email address that uniquely identifies you."
            requires :case_number, type: String, desc: "The case number"
            requires :case_type, type: String, desc: "The case type i.e trial"
            optional :cms_number, type: String, desc: "The CMS number"
          end

          def args
            user = User.advocates.find_by(email: params[:advocate_email])
            if user.blank?
              raise API::V1::ArgumentError, 'advocate_email is invalid'
            else
              {
                advocate_id: user.persona_id,
                creator_id:  user.persona_id,
                case_number: params[:case_number],
                case_type:   params[:case_type],
                cms_number:  params[:cms_number]
              }
            end
          end

          # return true, false or http response for api errors
          def claim_args_valid?
            begin
              ::Claim.new(args).valid?
            rescue API::V1::ArgumentError => ae
              arg_errors_response(ae)
            end
          end

          def arg_errors_response(e)
            if e.message.include?('advocate_email')
              return { status: 400, body: { error: e.message } }
            else
              raise
            end
          end

        end

        desc "Create a claim."

        params do
          use :claim_creation
        end

        post do
          arg_response = claim_args_valid?
          if arg_response == true
            ::Claim.create!(args)
          else
            status arg_response[:status]
            arg_response[:body]
          end
        end

        desc "Validate a claim."

        params do
          use :claim_creation
        end

        post '/validate' do
          arg_response = claim_args_valid?
          if arg_response.is_a?(Hash)
            status arg_response[:status]
            arg_response[:body]
          else
            status 200
            arg_response
          end
        end

      end

      add_swagger_documentation hide_documentation_path: true
      end
    end
  end
end
