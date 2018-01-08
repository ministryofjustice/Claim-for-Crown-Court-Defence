module API
  module V2
    module ClaimParamsHelper
      extend Grape::API::Helpers

      params :common_injection_params do
        optional :api_key, type: String, desc: 'REQUIRED: The API authentication key of the user'
        requires :uuid, type: String, desc: 'REQUIRED: Claim UUID'
      end

      # for a given API class its entity class should be
      # in API::Entities::<class_name_of_api_object>
      # e.g. API::V2::Fred --> API::Entities::Fred
      def entity_class
        class_name = options[:for].to_s.demodulize
        "API::Entities::#{class_name}".constantize
      end
    end
  end
end
