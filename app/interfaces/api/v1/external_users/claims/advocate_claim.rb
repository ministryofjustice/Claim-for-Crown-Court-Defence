module API::V1::ExternalUsers
  module Claims
    class AdvocateClaim < Grape::API
      helpers API::V1::ClaimHelper

      params do
        use :common_params

        optional :advocate_email, type: String, desc: 'DEPRECATED: Use instead user_email.'
        optional :user_email, type: String, desc: 'REQUIRED: The ADP account email address that uniquely identifies the advocate to whom this claim belongs.'

        optional :advocate_category, type: String, desc: "REQUIRED: The category of the advocate", values: Settings.advocate_categories
        optional :first_day_of_trial, type: String, desc: "REQUIRED: YYYY-MM-DD", standard_json_format: true
        optional :estimated_trial_length, type: Integer, desc: "REQUIRED: The estimated trial length in days"
        optional :actual_trial_length, type: Integer, desc: "REQUIRED: The actual trial length in days"
        optional :trial_concluded_at, type: String, desc: "REQUIRED: The date the trial concluded (YYYY-MM-DD)", standard_json_format: true
        optional :retrial_started_at, type: String, desc: "REQUIRED for retrials: YYYY-MM-DD", standard_json_format: true
        optional :retrial_estimated_length, type: Integer, desc: "REQUIRED for retrials: The estimated retrial length in days"
        optional :retrial_actual_length, type: Integer, desc: "REQUIRED for retrials: The actual retrial length in days"
        optional :retrial_concluded_at, type: String, desc: "REQUIRED for retrials: YYYY-MM-DD", standard_json_format: true
        optional :cms_number, type: String, desc: "OPTIONAL: The CMS number"
        optional :additional_information, type: String, desc: "OPTIONAL: Any additional information"
        optional :apply_vat, type: Boolean, desc: "OPTIONAL: Include VAT (JSON Boolean data type: true or false)"
        optional :trial_fixed_notice_at, type: String, desc: "OPTIONAL: YYYY-MM-DD", standard_json_format: true
        optional :trial_fixed_at, type: String, desc: "OPTIONAL: YYYY-MM-DD", standard_json_format: true
        optional :trial_cracked_at, type: String, desc: "OPTIONAL: YYYY-MM-DD", standard_json_format: true
        optional :trial_cracked_at_third, type: String, desc: "OPTIONAL: The third in which this case was cracked.", values: Settings.trial_cracked_at_third
      end

      namespace '/' do
        desc 'Create an Advocate claim.'
        post do
          create_resource(::Claim::AdvocateClaim)
          status api_response.status
          api_response.body
        end

        desc 'Validate an Advocate claim.'
        post '/validate' do
          validate_resource(::Claim::AdvocateClaim)
          status api_response.status
          api_response.body
        end
      end

    end
  end
end