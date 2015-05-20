class Claims::FinancialSummary

  def initialize(context)
    @context = context
  end

  def outstanding_claims
    @context.claims.unscope(:includes).outstanding
  end

  def authorised_claims
    @context.claims.unscope(:includes).authorised
  end

  def total_outstanding_claim_value
    outstanding_claims.map(&:total).sum # .sum(:total) causes incorrect total in some scenarios, hence map(&:total).sum instead
  end

  def total_authorised_claim_value
    authorised_claims.map(&:total).sum
  end

end
