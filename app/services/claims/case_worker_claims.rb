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
        current_claims
      when 'archived'
        archived_claims
      when 'allocated'
        allocated_claims
      when 'unallocated'
        unallocated_claims
      else
        raise ArgumentError, format('Unknown action: %{s}', s: action)
      end
    end

    private

    def current_claims
      Remote::Claim.user_allocations(current_user, criteria)
    end

    def archived_claims
      Remote::Claim.archived(current_user, criteria)
    end

    def allocated_claims
      Remote::Claim.allocated(current_user, criteria)
    end

    def unallocated_claims
      Remote::Claim.unallocated(current_user, criteria)
    end
  end
end
