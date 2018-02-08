module Claims
  class ExternalUserActions
    def self.all
      Settings.claim_actions
    end

    def self.available_for(claim)
      if claim.applicable_for_written_reasons?
        Settings.claim_actions
      else
        Settings.claim_actions.reject { |option| option.eql?('Request written reasons') }
      end
    end
  end
end
