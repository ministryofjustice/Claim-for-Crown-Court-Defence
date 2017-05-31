module Claims
  class ExternalUserClaimUpdater
    attr_accessor :claim, :current_user

    def initialize(claim, current_user:)
      self.claim = claim
      self.current_user = current_user
    end

    def delete
      claim.soft_delete
    end

    def archive
      claim.archive_pending_delete!(audit_attributes)
    end

    def clone_rejected
      claim.clone_rejected_to_new_draft(audit_attributes)
    end

    def request_redetermination
      claim.redetermine!(audit_attributes)
    end

    def request_written_reasons
      claim.await_written_reasons!(audit_attributes)
    end

    def submit
      claim.submit(audit_attributes)
    end

    private

    def audit_attributes
      { author_id: current_user&.id }
    end
  end
end
