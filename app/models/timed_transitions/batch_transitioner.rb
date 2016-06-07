
module TimedTransitions
  class BatchTransitioner
    def run
      claims = Transitioner.candidate_claims
      claims.each do |claim| 
        transitioner = Transitioner.new(claim)
        transitioner.run
      end
    end
  end
end
