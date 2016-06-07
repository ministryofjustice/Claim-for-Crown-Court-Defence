module TimedTransitions
  class Transitioner
    @@timed_transition_specifications = {
      authorised:               Specification.new(:authorised, 60, :archive),
      part_authorised:          Specification.new(:part_authorised, 60, :archive),
      refused:                  Specification.new(:refused, 60, :archive),
      rejected:                 Specification.new(:rejected, 60, :archive),
      archived_pending_delete:  Specification.new(:archived_pending_delete, 60, :destroy)
    }

    # generates sql to retrieve all claims in a state from which a timed transition can be made.
    #
    def self.candidate_claims
      Claim::BaseClaim.where('state in (?)', candidate_states)
    end


    def self.candidate_states
      @@timed_transition_specifications.keys
    end


    def initialize(claim)
      @claim = claim
    end

    def run
      specification = @@timed_transition_specifications[@claim.state.to_sym]
      if @claim.last_state_transition_time < specification.number_of_days.days.ago
        send(specification.method)
      end
    end


    private

    def archive
      @claim.archive_pending_delete!
    end


    def destroy
      @claim.destroy
    end 
  end
end