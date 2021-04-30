class ClaimSearchService
  class Base
    def initialize(search = nil, _options = {})
      @search = search || self
    end

    def run
      Claim::BaseClaim.active
    end
  end
end
