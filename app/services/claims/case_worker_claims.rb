module Claims
  class CaseWorkerClaims
    attr_accessor :current_user, :action, :criteria

    def initialize(current_user:, action:, criteria:)
      self.current_user = current_user
      self.action = action
      self.criteria = criteria
    end

    def claims
      case action
      when 'current'
        current_allocated_claims
      when 'archived'
        archived_claims
      when 'allocated'
        # TODO: to be implemented
      when 'unallocated'
        # TODO: to be implemented
      else
        raise ArgumentError, 'Unknown action: %s' % action
      end
    end

    def remote?
      Settings.case_workers_remote_allocations?
    end

    private

    def current_allocated_claims
      if remote?
        Remote::Claim.allocated(current_user, criteria)
      else
        current_user.claims.caseworker_dashboard_under_assessment
      end
    end

    def archived_claims
      if remote?
        Remote::Claim.archived(current_user, criteria)
      else
        Claim::BaseClaim.active.caseworker_dashboard_archived
      end
    end
  end
end
