class ClaimApiEndpoints
  CREATE_URL_PATTERN = '/api/external_users/claims%{type}'
  VALIDATE_URL_PATTERN = '/api/external_users/claims%{type}/validate'
  FORBIDDEN_CLAIM_VERBS = [:get, :put, :patch, :delete]

  cattr_accessor :type

  class << self
    def for(type)
      self.type = type
      self
    end

    def forbidden_verbs
      FORBIDDEN_CLAIM_VERBS
    end

    def create
      CREATE_URL_PATTERN % { type: namespace }
    end

    def validate
      VALIDATE_URL_PATTERN % { type: namespace }
    end

    def all
      [create, validate]
    end

    private

    def namespace
      self.type.to_sym == :advocate ? '' : "/#{self.type}"
    end
  end
end
