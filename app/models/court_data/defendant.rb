class CourtData
  class Defendant
    attr_reader :claim, :hmcts

    def initialize(claim: nil, hmcts: nil)
      @claim = claim
      @hmcts = hmcts
    end
  end
end
