
module TimedTransitions
  class BatchTransitioner

    def initialize(options)
      @dummy = options[:dummy]
    end

    def run
      claims_ids = Transitioner.candidate_claims_ids
      claims_ids.each do |claim_id|
        claim = Claim::BaseClaim.find claim_id
        transitioner = Transitioner.new(claim, @dummy)
        transitioner.run
      end
    end

  end
end