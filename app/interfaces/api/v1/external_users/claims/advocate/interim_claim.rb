module API::V1::ExternalUsers
  module Claims
    module Advocate
      class InterimClaim < Grape::API
        helpers API::V1::ClaimParamsHelper

        params do
          LOCAL_I18N_SCOPE = %i[api v1 external_users claims advocate_claim params].freeze

          def local_t(attribute, scope = LOCAL_I18N_SCOPE)
            I18n.t(attribute.to_s, scope: scope)
          end

          optional :api_key, type: String, desc: 'REQUIRED: The API authentication key of the provider'
          optional :creator_email, type: String, desc: I18n.t('api.v1.common_params.creator_email')
          optional :court_id, type: Integer, desc: 'REQUIRED: The unique identifier for this court'
          optional :offence_id, type: Integer, desc: 'REQUIRED: The unique identifier for this offence.'
          optional :case_number, type: String, desc: 'REQUIRED: The case number'
          optional :providers_ref, type: String, desc: 'OPTIONAL: Providers reference number'
          optional :cms_number, type: String, desc: 'OPTIONAL: The CMS number'
          optional :additional_information, type: String, desc: 'OPTIONAL: Any additional information'
          optional :apply_vat, type: Boolean, desc: 'OPTIONAL: Include VAT (JSON Boolean data type: true or false)'
          use :user_email
          optional :advocate_category,
                   type: String,
                   desc: local_t(:advocate_category),
                   values: Settings.agfs_reform_advocate_categories
        end

        namespace :advocate do
          namespace :interim do
            desc 'Create an Advocate Interim claim.'
            post do
              create_resource(::Claim::AdvocateInterimClaim)
              status api_response.status
              api_response.body
            end

            desc 'Validate an Advocate Interim claim.'
            post '/validate' do
              validate_resource(::Claim::AdvocateInterimClaim)
              status api_response.status
              api_response.body
            end
          end
        end
      end
    end
  end
end
