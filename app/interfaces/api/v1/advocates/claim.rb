module API
  module V1
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
              raise ArgumentError, 'advocate_email is invalid'
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

          def claim_valid?
            ::Claim.new(args).valid?
          end

        end

        desc "Create a claim."

        params do
          use :claim_creation
        end

        post do

          begin
            claim_valid?
            ::Claim.create!(args)
          rescue ArgumentError => ae
            if ae.message.include?('advocate_email')
              status 400
              { error: ae.message }
            else
              raise
            end
          end

        end

        desc "Validate a claim."

        params do
          use :claim_creation
        end

        post '/validate' do
          status 200

          begin
            claim_valid?
          rescue ArgumentError => ae
            if ae.message.include?('advocate_email')
              status 400
              { error: ae.message }
            else
              raise
            end
          end

        end

      end

      add_swagger_documentation hide_documentation_path: true
      end
    end
  end
end
