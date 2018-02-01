module Claims
  class ExternalUserActions
    def self.all
      Settings.claim_actions
    end

    def self.available_for(claim)
      [] << Settings.claim_actions[claim.applicable_for_written_reasons? ? 1 : 0]
    end
  end
end
