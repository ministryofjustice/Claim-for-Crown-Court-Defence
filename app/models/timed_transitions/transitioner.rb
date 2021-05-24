module TimedTransitions
  class Transitioner
    attr_accessor :success

    @@timed_transition_specifications = {
      draft: Specification.new(:draft, Settings.timed_transition_stale_weeks, :destroy_claim),
      authorised: Specification.new(:authorised, Settings.timed_transition_stale_weeks, :archive),
      part_authorised: Specification.new(:part_authorised, Settings.timed_transition_stale_weeks, :archive),
      refused: Specification.new(:refused, Settings.timed_transition_stale_weeks, :archive),
      rejected: Specification.new(:rejected, Settings.timed_transition_stale_weeks, :archive),
      archived_pending_delete: Specification.new(:archived_pending_delete,
                                                 Settings.timed_transition_pending_weeks,
                                                 :destroy_claim)
    }

    def self.candidate_claims_ids
      Claim::BaseClaim.where(state: candidate_states)
                      .where('updated_at < ?', Settings.timed_transition_stale_weeks.weeks.ago).pluck(:id)
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
      !success.nil?
    end

    private

    def log_level
      @dummy ? :debug : :info
    end

    def process_stale_claim
      specification = @@timed_transition_specifications[@claim.state.to_sym]
      last_transition = @claim.last_state_transition_time
      return unless last_transition.nil? || last_transition < specification.period_in_weeks.weeks.ago
      send(specification.method)
    end

    def archive
      values = @claim.hardship? ? hardship_archive_checks : archive_checks
      @claim.send(values[:event], reason_code: ['timed_transition']) unless @dummy
      @claim.reload # not sure if needed
      log(log_level,
          action: 'archive',
          message: values[:message],
          succeeded: @claim.send(values[:check]))
      self.success = @claim.send(values[:check])
    rescue StandardError => e
      log(:error,
          action: 'archive',
          message: values[:error_message],
          succeeded: @claim.reload.send(values[:check]),
          error: e.message)
    end

    def hardship_archive_checks
      {
        event: :archive_pending_review!,
        message: 'Archiving claim pending review',
        error_message: 'Archiving claim pending review failed!',
        check: :archived_pending_review?
      }
    end

    def archive_checks
      {
        event: :archive_pending_delete!,
        message: 'Archiving claim',
        error_message: 'Archiving claim failed!',
        check: :archived_pending_delete?
      }
    end

    def destroy_claim
      Stats::MIData.import(@claim) && @claim.destroy unless @dummy
      log(log_level,
          action: 'destroy',
          message: 'Destroying soft-deleted claim',
          succeeded: @claim.destroyed?)
      self.success = @claim.destroyed?
    rescue StandardError => e
      log(:error,
          action: 'destroy',
          message: 'Destroying soft-deleted claim failed!',
          succeeded: @claim.destroyed?,
          error: e.message)
    end

    def log(level = :info, action:, message:, succeeded:, error: nil)
      LogStuff.send(
        level.to_sym,
        'TimedTransitions::Transitioner',
        action: action,
        claim_id: @claim.id,
        claim_state: @claim.state,
        softly_deleted_on: @claim.deleted_at,
        valid_until: @claim.valid_until,
        dummy_run: @dummy,
        error: error,
        succeeded: succeeded
      ) do
        message
      end
    end
  end
end
