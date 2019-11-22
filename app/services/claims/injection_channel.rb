module Claims
  class InjectionChannel
    def self.for(claim)
      return 'cccd_development' if claim.nil?
      claim.agfs? ? 'cccd_ccr_injection' : 'cccd_cclf_injection'
    end
  end
end
