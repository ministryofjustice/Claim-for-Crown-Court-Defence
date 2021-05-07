class ClaimSearchService
  class Scheme < Scope
    SCHEMAS = %w[agfs lgfs].freeze

    def self.decorate(search, scheme: nil, **_params)
      return search unless SCHEMAS.include? scheme

      new(search, scope: scheme)
    end
  end
end
