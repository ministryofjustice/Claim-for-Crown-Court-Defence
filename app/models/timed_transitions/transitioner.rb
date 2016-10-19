module TimedTransitions
  class Transitioner
    attr_accessor :success

    @@timed_transition_specifications = {
      draft:                    Specification.new(:draft, Settings.timed_transition_stale_weeks, :destroy_claim),
      authorised:               Specification.new(:authorised, Settings.timed_transition_stale_weeks, :archive),
      part_authorised:          Specification.new(:part_authorised, Settings.timed_transition_stale_weeks, :archive),
      refused:                  Specification.new(:refused, Settings.timed_transition_stale_weeks, :archive),
      rejected:                 Specification.new(:rejected, Settings.timed_transition_stale_weeks, :archive),
      archived_pending_delete:  Specification.new(:archived_pending_delete, Settings.timed_transition_pending_weeks, :destroy_claim)
    }

    def self.candidate_claims_ids
      Claim::BaseClaim.where(state: candidate_states).
          where('updated_at < ?', Settings.timed_transition_stale_weeks.weeks.ago).pluck(:id)
    end

    def self.softly_deleted_ids
      Claim::BaseClaim.where('deleted_at < ?', Settings.timed_transition_soft_delete_weeks.weeks.ago).pluck(:id)
    end

    def self.candidate_states
      @@timed_transition_specifications.keys
    end

    def initialize(claim, dummy = false)
      @claim = claim
      @dummy = dummy
    end

    def run
      @claim.softly_deleted? ? destroy_claim : process_stale_claim
    end

    def success?
      !!success
    end

    private

    def is_dummy?
      @dummy
    end

    def log_level
      is_dummy? ? :debug : :info
    end

    def process_stale_claim
      specification = @@timed_transition_specifications[@claim.state.to_sym]
      if @claim.last_state_transition_time.nil? || @claim.last_state_transition_time < specification.period_in_weeks.weeks.ago
        send(specification.method)
      end
    end

    def archive
      LogStuff.send(log_level, 'TimedTransitions::Transitioner',
                    action: 'archive',
                    claim_id: @claim.id,
                    softly_deleted_on: @claim.deleted_at,
                    dummy_run: @dummy) do
                      'Archiving claim'
                    end
      @claim.archive_pending_delete!(reason_code: 'timed_transition') unless is_dummy?
      self.success = true
    end


    def destroy_claim
      LogStuff.send(log_level, 'TimedTransitions::Transitioner',
                      action: 'destroy',
                      claim_id: @claim.id,
                      claim_state: @claim.state,
                      softly_deleted_on: @claim.deleted_at,
                      dummy_run: @dummy) do
                        'Destroying soft-deleted claim'
                      end
      @claim.destroy unless is_dummy?
      self.success = true
    end 
  end
end