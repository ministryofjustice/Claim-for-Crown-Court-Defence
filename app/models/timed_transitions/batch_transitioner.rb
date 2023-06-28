module TimedTransitions
  class BatchTransitioner
    attr_reader :dummy, :limit, :transitions_counter

    def initialize(dummy: false, limit: 10_000, notifier: nil)
      @dummy = dummy
      @limit = limit
      @notifier = notifier
      @transitions_counter = 0
      @tally = { processed: 0, failed: 0 }
    end

    def run
      claims_ids = Transitioner.candidate_claims_ids
      softly_deleted_ids = Transitioner.softly_deleted_ids
      found_ids = (claims_ids | softly_deleted_ids)

      log_start
      found_ids.each do |claim_id|
        transition(claim_id)
        break if limit_reached?
      end
      log_end
    end

    private

    def transition(claim_id)
      claim = Claim::BaseClaim.find(claim_id)
      transitioner = Transitioner.new(claim, dummy:)
      transitioner.run
      update_state(transitioner)
    end

    def increment_counter
      @transitions_counter += 1
    end

    def update_state(transitioner)
      if transitioner.success?
        increment_counter
        @tally[:processed] += 1
      else
        @tally[:failed] += 1
      end
    end

    def limit_reached?
      return false if limit.zero?
      transitions_counter >= limit
    end

    def started_at
      @started_at ||= DateTime.current
    end

    def finished_at
      @finished_at ||= DateTime.current
    end

    def log_start
      log(:info,
          'Starting processing of stale claims',
          started_at:)
    end

    def log_end
      if @notifier && @tally[:failed].positive?
        @notifier.build_payload(**@tally)
        @notifier.send_message
      end

      log(:info,
          'Finished processing of stale claims',
          started_at:,
          finished_at:,
          claims_processed: transitions_counter,
          seconds_taken: finished_at.to_i - started_at.to_i)
    end

    def log(level, message, options)
      LogStuff.send(
        level.to_sym,
        'TimedTransitions::BatchTransitioner',
        environment: ENV.fetch('ENV', nil),
        limit:,
        started_at: options[:started_at],
        claims_processed: options[:claims_processed],
        finished_at: options[:finished_at],
        seconds_taken: options[:seconds_taken]
      ) do
        message
      end
    end
  end
end
