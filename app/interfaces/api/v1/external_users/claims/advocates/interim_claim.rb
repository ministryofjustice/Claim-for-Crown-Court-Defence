module API
  module V1
    module ExternalUsers
      module Claims
        module Advocates
          class InterimClaim < Grape::API
            helpers API::V1::ClaimParamsHelper

            params do
              def i18n_scope
                %i[api v1 external_users claims advocate_claim params]
              end

              def local_t(attribute)
                I18n.t(attribute.to_s, scope: i18n_scope)
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
              use :legacy_agfs_params
              use :advocate_category_agfs_reform
              optional :main_hearing_date,
                       type: String, desc: 'OPTIONAL: The date of the main hearing of the case (YYYY-MM-DD)',
                       standard_json_format: true
            end

            namespace :advocates do
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
  end
end
