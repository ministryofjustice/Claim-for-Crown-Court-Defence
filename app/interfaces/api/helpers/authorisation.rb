module API::Helpers
  module Authorisation
    class AuthorisationError < StandardError; end

    def authorise_claim!
      if claim_creator.provider != current_provider || claim_user.provider != current_provider
        authorisation_error('Creator and advocate/litigator must belong to the provider')
      end
    end

    def authenticate_provider_key!
      authorisation_error if current_provider.nil?
    end

    def authenticate_key!
      authorisation_error if current_user.nil?
    end

    private

    def authorisation_error(message = 'Unauthorised')
      Rails.logger.info '[api authorisation error] %s' % message
      raise AuthorisationError, message
    end
  end
end
