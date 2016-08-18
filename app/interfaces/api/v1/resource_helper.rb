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

    def claim_user
      @claim_user ||= find_user_by_email(email: claim_user_email, relation: claim_user_type)
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
      User.active.external_users.find_by(email: email).try(:persona) || (raise API::V1::ArgumentError, "#{relation} email is invalid")
    end

    def lgfs_schema?
      namespace =~ /\/claims\/(final|interim|transfer)/
    end

    def claim_user_email
      return params.delete(:user_email) if lgfs_schema?
      params.delete(:advocate_email) || params.delete(:user_email)
    end

    def claim_user_type
      lgfs_schema? ? 'Litigator' : 'Advocate'
    end
  end
end
