module TimedTransitions
  class BatchTransitioner
    attr_reader :dummy, :limit, :transitions_counter

    def initialize(options = {})
      @dummy = options.fetch(:dummy, false)
      @limit = options.fetch(:limit, '10000').to_i
      @transitions_counter = 0
      @failed_transitions = []
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
      transitioner = Transitioner.new(claim, dummy)
      transitioner.run
      update_state(transitioner, claim_id)
    end

    def increment_counter
      @transitions_counter += 1
    end

    def update_state(transitioner, claim_id)
      if transitioner.success?
        increment_counter
      else
        @failed_transitions < claim_id
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
          started_at: started_at)
    end

    def log_end
      slack_notifier.build_payload(processed: @transitions_counter, failed: @failed_transitions)
      slack_notifier.send_message

      log(:info,
          'Finished processing of stale claims',
          started_at: started_at,
          finished_at: finished_at,
          claims_processed: transitions_counter,
          seconds_taken: finished_at.to_i - started_at.to_i)
    end

    def log(level, message, options)
      LogStuff.send(
        level.to_sym,
        'TimedTransitions::BatchTransitioner',
        environment: ENV.fetch('ENV', nil),
        limit: limit,
        started_at: options[:started_at],
        claims_processed: options[:claims_processed],
        finished_at: options[:finished_at],
        seconds_taken: options[:seconds_taken]
      ) do
        message
      end
    end

    def slack_notifier
      @slack_notifier ||= SlackNotifier.new('laa-cccd-alerts', formatter: SlackNotifier::Formatter::Transitioner.new)
    end
  end
end
