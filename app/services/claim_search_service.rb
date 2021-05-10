class ClaimSearchService
  FILTERS = [
    ClaimSearchService::State,
    ClaimSearchService::Keyword,
    ClaimSearchService::Scheme,
    # This needs to be last because of how it is implemented
    ClaimSearchService::CurrentUser
  ].freeze

  def self.call(params)
    new(params).call
  end

  def initialize(**params)
    @search = FILTERS.inject(ClaimSearchService::Base.new) do |partial_search, filter|
      filter.decorate(partial_search, params)
    end
  end

  def call
    @search.run
  end
end
