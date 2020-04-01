# DEPRECATED: see advocates/final[/validate] endpoints
module API::V1::ExternalUsers
  module Claims
    class AdvocateClaim < Grape::API
      helpers API::V1::ClaimParamsHelper

      params do
        def i18n_scope
          %i[api v1 external_users claims advocate_claim params]
        end

        def local_t(attribute)
          I18n.t(attribute.to_s, scope: i18n_scope)
        end

        use :common_params
        use :legacy_agfs_params
        optional :advocate_category,
                 type: String,
                 desc: local_t(:advocate_category),
                 values: (Settings.advocate_categories + Settings.agfs_reform_advocate_categories).uniq

        use :common_trial_params
        use :common_agfs_params
      end

      namespace '/' do
        desc 'DEPRECATED: Create an Advocate final claim. see advocates/final endpoint'
        post do
          deprecate(datetime: Time.new(2020, 9, 30), link: "#{request.base_url}/api/release_notes")
          create_resource(::Claim::AdvocateClaim)
          status api_response.status
          api_response.body
        end

        desc 'DEPRECATED: Validate an Advocate final claim. see advocates/final/validate endpoint'
        post '/validate' do
          deprecate(datetime: Time.new(2020, 9, 30), link: "#{request.base_url}/api/release_notes")
          validate_resource(::Claim::AdvocateClaim)
          status api_response.status
          api_response.body
        end
      end
    end
  end
end
