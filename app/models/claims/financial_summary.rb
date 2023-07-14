class Claims::FinancialSummary
  def initialize(claims)
    @claims = claims
  end

  def outstanding_claims
    @claims.outstanding
  end

  def authorised_claims
    @claims
      .any_authorised
      .joins(:determinations)
      .where('determinations.updated_at >= ?', Time.zone.now.beginning_of_week)
      .distinct
  end

  def total_outstanding_claim_value
    outstanding_claims.sum { |c| c.total + c.vat_amount }
  end

  def total_authorised_claim_value
    authorised_claims.sum(&:amount_assessed)
  end
end
