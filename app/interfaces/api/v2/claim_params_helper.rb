module API
  module V2
    module ClaimParamsHelper
      extend Grape::API::Helpers

      params :common_injection_params do
        optional :api_key, type: String, desc: 'REQUIRED: The API authentication key of the user'
        requires :uuid, type: String, desc: 'REQUIRED: Claim UUID'
      end

      # For a given API claim class its entity class should be
      # in API::Entities::<class_name_of_api_object>
      # e.g. API::V2::Fred --> API::Entities::Fred
      def entity_class
        "API::Entities::#{api_class}".constantize
      end

      private

      def api_class
        options[:for].to_s.demodulize
      end
    end
  end
end
