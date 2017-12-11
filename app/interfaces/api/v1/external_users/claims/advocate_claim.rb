module API::V1::ExternalUsers
  module Claims
    class AdvocateClaim < Grape::API
      helpers API::V1::ClaimParamsHelper

      params do
        use :common_params
        optional :advocate_email, type: String, desc: 'DEPRECATED: Use instead user_email.'
        optional :user_email,
                 type: String,
                 desc: I18n.t('api.v1.external_users.claims.advocate_claim.params.user_email')
        optional :advocate_category,
                 type: String,
                 desc: 'REQUIRED: The category of the advocate',
                 values: Settings.advocate_categories

        use :common_trial_params
        optional :actual_trial_length, type: Integer, desc: 'REQUIRED/UNREQUIRED: The actual trial length in days'
        optional :retrial_actual_length, type: Integer, desc: 'REQUIRED for retrials: The actual retrial length in days'
        optional :retrial_concluded_at,
                 type: String,
                 desc: 'REQUIRED for retrials: YYYY-MM-DD',
                 standard_json_format: true

        optional :trial_fixed_notice_at, type: String, desc: 'OPTIONAL: YYYY-MM-DD', standard_json_format: true
        optional :trial_fixed_at, type: String, desc: 'OPTIONAL: YYYY-MM-DD', standard_json_format: true
        optional :trial_cracked_at, type: String, desc: 'OPTIONAL: YYYY-MM-DD', standard_json_format: true
        optional :trial_cracked_at_third,
                 type: String,
                 desc: 'OPTIONAL: The third in which this case was cracked.',
                 values: Settings.trial_cracked_at_third
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
