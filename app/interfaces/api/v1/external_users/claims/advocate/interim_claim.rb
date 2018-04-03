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

          use :common_params
          use :legacy_agfs_params
          optional :advocate_category,
                   type: String,
                   desc: local_t(:advocate_category),
                   values: Settings.agfs_reform_advocate_categories

          use :common_trial_params
          use :common_agfs_params
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
