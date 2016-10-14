
module TimedTransitions
  class BatchTransitioner

    def initialize(options = {})
      @dummy = options.fetch(:dummy, false)
      @limit = options[:limit].to_i
    end

    def run
      claims_ids = Transitioner.candidate_claims_ids
      softly_deleted_ids = Transitioner.softly_deleted_ids
      found_ids = (claims_ids | softly_deleted_ids)
      limit = @limit.zero? ? found_ids.size : @limit

      found_ids.sort.first(limit).each do |claim_id|
        claim = Claim::BaseClaim.find claim_id
        transitioner = Transitioner.new(claim, @dummy)
        transitioner.run
      end
    end

  end
end