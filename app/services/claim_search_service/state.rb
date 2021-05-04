class ClaimSearchService
  class State < Base
    def initialize(search, state:)
      super

      @state = state
    end

    def run
      @search.run.where(state: @state)
    end

    def self.decorate(search, state: nil, **_params)
      return search if state.blank?

      new(search, state: Array(state))
    end
  end
end
