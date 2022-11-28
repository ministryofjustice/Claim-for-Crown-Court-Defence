module API
  module V1
    module ExternalUsers
      module Claims
        module Advocates
          class FinalClaim < Grape::API
            helpers API::V1::ClaimParamsHelper

            params do
              def i18n_scope
                %i[api v1 external_users claims advocate_claim params]
              end

              def local_t(attribute)
                I18n.t(attribute.to_s, scope: i18n_scope)
              end
              use :common_params
              use :common_trial_params
              use :common_agfs_params
              use :legacy_agfs_params
              optional :advocate_category,
                       type: String,
                       desc: local_t(:advocate_category),
                       values: (Settings.advocate_categories + Settings.agfs_reform_advocate_categories + ['KC']).uniq
              optional :main_hearing_date,
                       type: String,
                       desc: 'OPTIONAL: The date of the main hearing of the case (YYYY-MM-DD)',
                       standard_json_format: true
            end

            namespace :advocates do
              namespace :final do
                desc 'Create an Advocate final claim.'
                post do
                  create_resource(::Claim::AdvocateClaim)
                  status api_response.status
                  api_response.body
                end

                desc 'Validate an Advocate final claim.'
                post '/validate' do
                  validate_resource(::Claim::AdvocateClaim)
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
