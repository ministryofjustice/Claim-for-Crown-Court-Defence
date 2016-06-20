module API::V1
  module ResourceHelper
    extend Grape::API::Helpers

    def declared_params
      declared(params, include_missing: false)
    end

    def claim_source
      params.source || 'api'
    end

    def claim_id
      ::Claim::BaseClaim.find_by(uuid: params.claim_id).try(:id) || (raise API::V1::ArgumentError, 'Claim cannot be blank')
    end

    def claim_creator
      @claim_creator ||= find_user_by_email(email: params.delete(:creator_email), relation: 'Creator')
    end

    # TODO: support user_email param (litigators)
    def claim_user
      @claim_user ||= find_user_by_email(email: params.delete(:advocate_email), relation: 'Advocate')
    end

    def current_provider
      @current_provider ||= Provider.find_by(api_key: params.delete(:api_key))
    end

    def create_resource(klass)
      API::V1::ApiHelper.create_resource(klass, params, api_response, arguments_proc)
    end

    def validate_resource(klass)
      API::V1::ApiHelper.validate_resource(klass, api_response, arguments_proc)
    end

    def arguments_proc
      method(:build_arguments).to_proc
    end

    def api_response
      @api_response ||= ApiResponse.new
    end

    def find_user_by_email(email:, relation:)
      User.external_users.find_by(email: email).try(:persona) || (raise API::V1::ArgumentError, "#{relation} email is invalid")
    end

  end
end
