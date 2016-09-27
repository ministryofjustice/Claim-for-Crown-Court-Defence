module API::Helpers
  module Authorisation
    class AuthorisationError < StandardError; end

    def authorise_claim!
      if claim_creator.provider != current_provider || claim_user.provider != current_provider
        raise AuthorisationError, 'Creator and advocate/litigator must belong to the provider'
      end
    end

    def authenticate_key!
      if current_provider.nil? || current_provider.api_key.blank?
        raise AuthorisationError, 'Unauthorised'
      end
    end

  end
end
