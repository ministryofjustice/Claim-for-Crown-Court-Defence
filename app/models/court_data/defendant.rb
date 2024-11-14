class CourtData
  class Defendant
    attr_reader :claim, :hmcts

    def initialize(claim: nil, hmcts: nil)
      @claim = claim
      @hmcts = hmcts
    end

    def maat_reference = @claim&.maat_reference || @hmcts&.maat_reference
  end
end
