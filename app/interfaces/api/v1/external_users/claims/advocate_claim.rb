module API::V1::ExternalUsers
  module Claims
    class AdvocateClaim < Grape::API
      helpers API::V1::ClaimParamsHelper

      params do
        LOCAL_I18N_SCOPE = %i[api v1 external_users claims advocate_claim params].freeze

        def local_t(attribute)
          I18n.t(attribute.to_s, scope: LOCAL_I18N_SCOPE)
        end

        use :common_params
        optional :advocate_email, type: String, desc: local_t(:advocate_email)
        optional :user_email, type: String, desc: local_t(:user_email)
        # TODO: this might need to be changed given there's a different list
        # of advocate categories depending on the fee scheme in use
        optional :advocate_category,
                 type: String,
                 desc: local_t(:advocate_category),
                 values: Settings.advocate_categories

        use :common_trial_params
        optional :actual_trial_length, type: Integer, desc: local_t(:actual_trial_length)
        optional :retrial_actual_length, type: Integer, desc: local_t(:retrial_actual_length)
        optional :retrial_concluded_at, type: String, desc: local_t(:retrial_concluded_at), standard_json_format: true
        optional :retrial_reduction, type: Boolean, desc: local_t(:retrial_reduction), documentation: { default: false }

        optional :trial_fixed_notice_at, type: String, desc: local_t(:trial_fixed_notice_at), standard_json_format: true
        optional :trial_fixed_at, type: String, desc: local_t(:trial_fixed_at), standard_json_format: true
        optional :trial_cracked_at, type: String, desc: local_t(:trial_cracked_at), standard_json_format: true
        optional :trial_cracked_at_third,
                 type: String,
                 desc: local_t(:trial_cracked_at_third),
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
