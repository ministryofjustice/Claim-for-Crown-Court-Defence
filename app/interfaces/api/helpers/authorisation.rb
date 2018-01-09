module API::Helpers
  module Authorisation
    class AuthorisationError < StandardError; end

    def authorise_claim!
      return unless claim_creator.provider != current_provider || claim_user.provider != current_provider
      authorisation_error('Creator and advocate/litigator must belong to the provider')
    end

    def authenticate_provider_key!
      authorisation_error if current_provider.nil?
    end

    def authenticate_key!
      authorisation_error if current_user.nil?
    end

    def authenticate_user_is?(persona)
      authorisation_error unless current_user&.persona_type.eql?(persona)
    end

    private

    def authorisation_error(message = 'Unauthorised')
      Rails.logger.info format('[api authorisation error] %{s}', s: message)
      raise AuthorisationError, message
    end
  end
end
