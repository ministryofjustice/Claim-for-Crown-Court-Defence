class ClaimSearchService
  FILTERS = [
    ClaimSearchService::State
  ].freeze

  def self.call(params)
    new(params).call
  end

  def initialize(params = {})
    @search = FILTERS.inject(ClaimSearchService::Base.new) do |partial_search, filter|
      filter.decorate(partial_search, params)
    end
  end

  def call
    @search.run
  end
end
