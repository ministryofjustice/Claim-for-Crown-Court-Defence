module TimedTransitions
  class Transitioner

    @@logger = Logger.new Settings.timed_transition_log_path

    @@timed_transition_specifications = {
      authorised:               Specification.new(:authorised, 60, :archive),
      part_authorised:          Specification.new(:part_authorised, 60, :archive),
      refused:                  Specification.new(:refused, 60, :archive),
      rejected:                 Specification.new(:rejected, 60, :archive),
      archived_pending_delete:  Specification.new(:archived_pending_delete, 60, :destroy)
    }

    # generates sql to retrieve all claims in a state from which a timed transition can be made.
    #
    def self.candidate_claims_ids
      Claim::BaseClaim.where('state in (?)', candidate_states).pluck(:id)
    end

    def self.candidate_states
      @@timed_transition_specifications.keys
    end

    def initialize(claim, dummy = false)
      @claim = claim
      @dummy = dummy
    end

    def run
      specification = @@timed_transition_specifications[@claim.state.to_sym]
      if @claim.last_state_transition_time < specification.number_of_days.days.ago
        if @dummy
          @@logger.debug "Dummy run: would have transitioned claim id #{@claim.id} - #{@claim.case_number} from #{@claim.state} to #{specification.method}"
        else
          send(specification.method, reason_code: 'timed_transition')
        end
      end
    end

    private

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