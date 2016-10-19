module TimedTransitions
  class BatchTransitioner
    attr_accessor :transitions_counter

    def initialize(options = {})
      @dummy = options.fetch(:dummy, false)
      @limit = options[:limit].to_i
      @transitions_counter = 0
    end

    def run
      claims_ids = Transitioner.candidate_claims_ids
      softly_deleted_ids = Transitioner.softly_deleted_ids
      found_ids = (claims_ids | softly_deleted_ids)

      found_ids.each do |claim_id|
        claim = Claim::BaseClaim.find claim_id

        transitioner = Transitioner.new(claim, @dummy)
        transitioner.run
        increment_counter if transitioner.success?

        break if limit_reached?
      end
    end

    def increment_counter
      @transitions_counter += 1
    end

    def limit_reached?
      return false if @limit.zero?
      @transitions_counter >= @limit
    end
  end
end
