module API
  module V1

    class Error < StandardError; end
    class ArgumentError < Error; end

    module Advocates


      class Claim < Grape::API

        version 'v1', using: :header, vendor: 'Advocate Defence Payments'
        format :json
        prefix 'api/advocates'
        content_type :json, 'application/json'

        resource :claims, desc: 'Create or Validate' do

          helpers do
            params :claim_parameters do

              # REQUIRED params (note: use optional but describe as required in order to let model validations bubble-up)
              optional :advocate_email, type: String,     desc: "REQUIRED: Your ADP account email address that uniquely identifies you."
              optional :case_number, type: String,        desc: "REQUIRED: The case number"
              optional :case_type_id, type: Integer,      desc: "REQUIRED: The unique identifier of the case type"
              optional :indictment_number, type: String,  desc: "REQUIRED: The indictment number"
              optional :first_day_of_trial, type: Date,   desc: "REQUIRED: YYYY/MM/DD"
              optional :estimated_trial_length, type: Integer,  desc: "REQUIRED: The estimated trial length in days"
              optional :actual_trial_length, type: Integer,     desc: "REQUIRED: The actual trial length in days"
              optional :trial_concluded_at, type: Date,         desc: "REQUIRED: The the trial concluded"
              optional :advocate_category, type: String, values: Settings.advocate_categories, desc: "REQUIRED: The category of the advocate"
              optional :offence_id, type: Integer,        desc: "REQUIRED: The unique identifier for this offence"
              optional :court_id, type: Integer,          desc: "REQUIRED: The unique identifier for this court"

              # OPTIONAL params
              optional :cms_number, type: String,               desc: "OPTIONAL: The CMS number"
              optional :additional_information , type: String,  desc: "OPTIONAL: Any additional information"
              optional :apply_vat , type: Boolean,              desc: "OPTIONAL: Include VAT (True or False)"
              optional :trial_fixed_notice_at, type: Date,      desc: "OPTIONAL: YYYY/MM/DD"
              optional :trial_fixed_at, type: Date,             desc: "OPTIONAL: YYYY/MM/DD"
              optional :trial_cracked_at, type: Date,           desc: "OPTIONAL: YYYY/MM/DD"
              optional :trial_cracked_at_third, type: String, values: Settings.trial_cracked_at_third, desc: "OPTIONAL: The third in which this case was cracked."

            end

            # def build_arguments
            #   user = User.advocates.find_by(email: params[:advocate_email])
            #   if user.blank?
            #     raise API::V1::ArgumentError, 'Advocate email is invalid'
            #   else
            #     {
            #       advocate_id:              user.persona_id,
            #       creator_id:               user.persona_id,
            #       source:                   'api',
            #       case_number:              params[:case_number],
            #       case_type_id:             params[:case_type_id],
            #       indictment_number:        params[:indictment_number],
            #       first_day_of_trial:       params[:first_day_of_trial],
            #       estimated_trial_length:   params[:estimated_trial_length],
            #       actual_trial_length:      params[:actual_trial_length],
            #       trial_concluded_at:       params[:trial_concluded_at],
            #       advocate_category:        params[:advocate_category],
            #       cms_number:               params[:cms_number],
            #       additional_information:   params[:additional_information],
            #       apply_vat:                params[:apply_vat],
            #       trial_fixed_notice_at:    params[:trial_fixed_notice_at],
            #       trial_fixed_at:           params[:trial_fixed_at],
            #       trial_cracked_at:         params[:trial_cracked_at],
            #       trial_cracked_at_third:   params[:trial_cracked_at_third],
            #       offence_id:               params[:offence_id],
            #       court_id:                 params[:court_id],
            #     }
            #   end
            # end

          end

          desc "Create a claim."

          params do
            use :claim_parameters
          end

          post do

            # OLD
            # --------------------------
            # begin
            #   arguments = build_arguments
            # rescue => error
            #   arguments_error = ApiHelper::ErrorResponse.new(error)
            #   status arguments_error.status
            #   return arguments_error.body
            # end

            # claim = ::Claim.create(arguments)

            # unless claim.errors.empty?
            #   error = ErrorResponse.new(claim)
            #   status error.status
            #   return error.body
            # end

            # status 201

            # api_response = { 'id' => claim.reload.uuid }.merge!(declared(params))
            # api_response

            # NEW
            # ------------------
            # create claim and output http usable response in expected format
            api_response = ApiHelper::ApiResponse.new()
            claim = ApiHelper.create_claim(params, api_response)
            status api_response.status
            return api_response.body

          end


          # ------------------------
          desc "Validate a claim."

          params do
            use :claim_parameters
          end

          post '/validate' do
            # OLD
            # ------------------------
            # begin
            #     arguments = build_arguments
            # rescue => error
            #   arguments_error = ApiHelper::ErrorResponse.new(error)
            #   status arguments_error.status
            #   return arguments_error.body
            # end

            # ------------------
            # claim = ::Claim.new(arguments)

            # if !claim.valid?
            #   error = ApiHelper::ErrorResponse.new(claim)
            #   status error.status
            #   return error.body
            # end

            # status 200
            # { valid: true }

            # NEW
            # ------------------
            # validate a claim and output http usable response in expected format
            api_response = ApiHelper::ApiResponse.new()
            claim = ApiHelper.validate_claim(params, api_response)
            status api_response.status
            return api_response.body

          end

        end
      end
    end
  end
end
