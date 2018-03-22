module Claims
  class FetchEligibleDocumentTypes
    def self.for(claim)
      new(claim).call
    end

    def initialize(claim)
      @claim = claim
    end

    def call
      return default_doc_types unless claim&.agfs?
      return fee_reform_doc_types if claim.interim?
      default_doc_types
    end

    private

    attr_reader :claim

    def default_doc_types
      DocType.all
    end

    def fee_reform_doc_types
      DocType.for_fee_reform
    end
  end
end
