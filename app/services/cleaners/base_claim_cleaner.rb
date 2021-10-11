module Cleaners
  class BaseClaimCleaner
    attr_accessor :claim

    delegate_missing_to :claim

    def initialize(claim)
      @claim = claim
    end
  end
end
