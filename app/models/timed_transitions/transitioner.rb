module TimedTransitions
  class Transitioner

    @@logger = Logger.new Settings.timed_transition_log_path

    @@timed_transition_specifications = {
      draft:                    Specification.new(:authorised, Settings.timed_transition_stale_weeks, :archive),
      authorised:               Specification.new(:authorised, Settings.timed_transition_stale_weeks, :archive),
      part_authorised:          Specification.new(:part_authorised, Settings.timed_transition_stale_weeks, :archive),
      refused:                  Specification.new(:refused, Settings.timed_transition_stale_weeks, :archive),
      rejected:                 Specification.new(:rejected, Settings.timed_transition_stale_weeks, :archive),
      archived_pending_delete:  Specification.new(:archived_pending_delete, Settings.timed_transition_pending_weeks, :destroy)
    }

    def self.candidate_claims_ids
      Claim::BaseClaim.where('state in (?)', candidate_states).pluck(:id)
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
      @claim.softly_deleted? ? process_softly_deleted_claim : process_stale_claim
    end

    private

    def process_softly_deleted_claim
      @@logger.info "Deleting claim #{@claim.id}: #{@claim.case_number} (softly deleted on #{@claim.deleted_at.strftime(Settings.date_format)}"
      @claim.destroy
    end

    def process_stale_claim
      specification = @@timed_transition_specifications[@claim.state.to_sym]
      if @claim.last_state_transition_time < specification.period_in_weeks.weeks.ago
        if @dummy
          @@logger.debug "Dummy run: would have transitioned claim id #{@claim.id} - #{@claim.case_number} from #{@claim.state} to #{specification.method}"
        else
          send(specification.method, reason_code: 'timed_transition')
        end
      end
    end

    def archive(options)
      @@logger.info "Changing state of claim #{@claim_id}: #{@claim.case_number} from #{@claim.state} to archived_pending_delete"
      @claim.archive_pending_delete!(options)
    end


    def destroy(_options)
      @@logger.info "Deleting claim #{@claim_id}: #{@claim.case_number}"
      @claim.destroy
    end 


  end
end