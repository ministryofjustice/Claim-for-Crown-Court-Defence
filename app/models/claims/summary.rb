class Claims::Summary

  def initialize(parent)
    @parent = parent
  end

  def outstanding_claims
    @parent.claims.outstanding
  end

  def authorised_claims
    @parent.claims.authorised
  end

  def total_outstanding_claim_value
    outstanding_claims.sum(:total)
  end

  def total_authorised_claim_value
    authorised_claims.sum(:total)
  end

end
