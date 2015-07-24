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
            requires :case_type, type: String, values: Settings.case_types, desc: "The case type i.e trial"
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

          # return true, http response for api arg errors or array of hashed errors from model
          def claim_args_valid?
            begin
              claim = ::Claim.new(args)
              if claim.valid?
                true
              else
                # contruct array of error message hashes from model
                error_messages = []
                claim.errors.full_messages.each do |error_message|
                  error_messages.push({ error: error_message })
                end
                { status: 400, body: error_messages }
              end
            rescue API::V1::ArgumentError => ae
              if ae.message.include?('advocate_email')
                return { status: 400, body: { error: ae.message } }
              else
                raise
              end
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
            if arg_response == true
              status 200
              arg_response
            else
              status arg_response[:status]
              arg_response[:body]
            end
          end

        end

        
      end
    end
  end
end
