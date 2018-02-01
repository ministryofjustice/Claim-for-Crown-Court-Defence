module Claims
  class ExternalUserActions
    def self.all
      Settings.claim_actions
    end
  end
end
