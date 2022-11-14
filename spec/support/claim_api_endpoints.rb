class ClaimApiEndpoints
  CREATE_URL_PATTERN = '/api/external_users/claims%{type}'.freeze
  VALIDATE_URL_PATTERN = '/api/external_users/claims%{type}/validate'.freeze
  FORBIDDEN_CLAIM_VERBS = %i[get put patch delete].freeze

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
      format(CREATE_URL_PATTERN, type: namespace)
    end

    def validate
      format(VALIDATE_URL_PATTERN, type: namespace)
    end

    def all
      [create, validate]
    end

    private

    def namespace
      type.to_sym == :advocate ? '' : "/#{type}"
    end
  end
end
