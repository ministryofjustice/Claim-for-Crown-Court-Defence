module Claims
  class InjectionChannel
    def self.for(claim)
      return 'cccd_development' if claim.nil?
      claim.agfs? ? Settings.slack.channel : 'cccd_cclf_injection'
    end
  end
end
