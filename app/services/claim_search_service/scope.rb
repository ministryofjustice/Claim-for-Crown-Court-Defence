class ClaimSearchService
  class Scope < Base
    def initialize(search, scope:)
      super

      @scope = scope
    end

    def run
      @search.run.send(@scope)
    end
  end
end
