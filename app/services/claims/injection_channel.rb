module Claims
  class InjectionChannel
    def self.for(claim)
      return 'cccd_development' if claim.nil?
      return 'cccd-k8s-injection' if Settings.aws&.response_queue&.match?('laa-get-paid')
      claim.agfs? ? 'cccd_ccr_injection' : 'cccd_cclf_injection'
    end
  end
end
