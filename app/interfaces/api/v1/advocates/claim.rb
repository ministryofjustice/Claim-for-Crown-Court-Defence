module API
  module V1
    module Advocates

      class Claim < GrapeApiHelper

        version 'v1', using: :header, vendor: 'Advocate Defence Payments'
        format :json
        prefix 'api/advocates'
        content_type :json, 'application/json'

        resource :claims, desc: 'Create or Validate' do

          helpers do

            include API::ExtractDate
            include API::V1::ApiHelper

            params :claim_params do
              # REQUIRED params (note: use optional but describe as required in order to let model validations bubble-up)
              optional :api_key, type: String,                    desc: "REQUIRED: The API authentication key of the chamber"
              optional :creator_email, type: String,              desc: "REQUIRED: The ADP administrator account email address that uniquely identifies the creator of the claim."
              optional :advocate_email, type: String,             desc: "REQUIRED: The ADP account email address that uniquely identifies the advocate to whom this claim belongs."
              optional :advocate_category, type: String,          desc: "REQUIRED: The category of the advocate", values: Settings.advocate_categories
              optional :court_id, type: Integer,                  desc: "REQUIRED: The unique identifier for this court"
              optional :case_type_id, type: Integer,              desc: "REQUIRED: The unique identifier of the case type"
              optional :case_number, type: String,                desc: "REQUIRED: The case number"
              optional :offence_id, type: Integer,                desc: "REQUIRED: The unique identifier for this offence"
              optional :first_day_of_trial, type: String,         desc: "REQUIRED: YYYY-MM-DD", standard_json_format: true
              optional :estimated_trial_length, type: Integer,    desc: "REQUIRED: The estimated trial length in days"
              optional :actual_trial_length, type: Integer,       desc: "REQUIRED: The actual trial length in days"
              optional :trial_concluded_at, type: String,         desc: "REQUIRED: The date the trial concluded (YYYY-MM-DD)", standard_json_format: true

              # OPTIONAL params
              optional :cms_number, type: String,               desc: "OPTIONAL: The CMS number"
              optional :additional_information , type: String,  desc: "OPTIONAL: Any additional information"
              optional :apply_vat , type: Boolean,              desc: "OPTIONAL: Include VAT (JSON Boolean data type: true or false)"
              optional :trial_fixed_notice_at, type: String,    desc: "OPTIONAL: YYYY-MM-DD", standard_json_format: true
              optional :trial_fixed_at, type: String,           desc: "OPTIONAL: YYYY-MM-DD", standard_json_format: true
              optional :trial_cracked_at, type: String,         desc: "OPTIONAL: YYYY-MM-DD", standard_json_format: true
              optional :trial_cracked_at_third, type: String,   desc: "OPTIONAL: The third in which this case was cracked.", values: Settings.trial_cracked_at_third

            end

            def build_arguments
              authenticated = ApiHelper.authenticate_claim!(params)
              {
                creator_id:               authenticated[:creator].id,
                advocate_id:              authenticated[:advocate].id,
                source:                   params[:source] || 'api',
                case_number:              params[:case_number],
                case_type_id:             params[:case_type_id],
                indictment_number:        params[:indictment_number],
                first_day_of_trial_dd:    extract_date(:day, params[:first_day_of_trial]),
                first_day_of_trial_mm:    extract_date(:month, params[:first_day_of_trial]),
                first_day_of_trial_yyyy:  extract_date(:year, params[:first_day_of_trial]),
                estimated_trial_length:   params[:estimated_trial_length],
                actual_trial_length:      params[:actual_trial_length],
                trial_concluded_at_dd:    extract_date(:day, params[:trial_concluded_at]),
                trial_concluded_at_mm:    extract_date(:month, params[:trial_concluded_at]),
                trial_concluded_at_yyyy:  extract_date(:year, params[:trial_concluded_at]),
                advocate_category:        params[:advocate_category],
                cms_number:               params[:cms_number],
                additional_information:   params[:additional_information],
                apply_vat:                params[:apply_vat],
                trial_fixed_notice_at_dd:    extract_date(:day, params[:trial_fixed_notice_at]),
                trial_fixed_notice_at_mm:    extract_date(:month, params[:trial_fixed_notice_at]),
                trial_fixed_notice_at_yyyy:  extract_date(:year, params[:trial_fixed_notice_at]),
                trial_fixed_at_dd:        extract_date(:day, params[:trial_fixed_at]),
                trial_fixed_at_mm:        extract_date(:month, params[:trial_fixed_at]),
                trial_fixed_at_yyyy:      extract_date(:year, params[:trial_fixed_at]),
                trial_cracked_at_dd:      extract_date(:day, params[:trial_cracked_at]),
                trial_cracked_at_mm:      extract_date(:month, params[:trial_cracked_at]),
                trial_cracked_at_yyyy:    extract_date(:year, params[:trial_cracked_at]),
                trial_cracked_at_third:   params[:trial_cracked_at_third],
                offence_id:               params[:offence_id],
                court_id:                 params[:court_id]
              }
            end

          end

          desc "Create a claim."

          params do
            use :claim_params
          end

          post do
            api_response = ApiResponse.new()
            ApiHelper.create_resource(::Claim, params, api_response, method(:build_arguments).to_proc)
            status api_response.status
            return api_response.body
          end

          # ------------------------
          desc "Validate a claim."

          params do
            use :claim_params
          end

          post '/validate' do
            api_response = ApiResponse.new()
            ApiHelper.validate_resource(::Claim, params, api_response, method(:build_arguments).to_proc)
            status api_response.status
            return api_response.body
          end

        end
      end
    end
  end
end
