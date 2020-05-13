module Claims
  class FetchEligibleDocumentTypes
    def self.for(claim)
      new(claim).call
    end

    def initialize(claim)
      @claim = claim
    end

    def call
      case claim.type
      when 'Claim::AdvocateInterimClaim'
        fee_reform_doc_types
      when 'Claim::LitigatorHardshipClaim'
        DocType.for_lgfs_hardship
      when 'Claim::AdvocateHardshipClaim'
        DocType.for_agfs_hardship
      else
        default_doc_types
      end
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
