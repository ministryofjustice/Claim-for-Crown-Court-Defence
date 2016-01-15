class Claims::FinancialSummary
  def initialize(context)
    @context = context
  end

  def outstanding_claims
    @context.claims.outstanding
  end

  def authorised_claims
    @context.claims.any_authorised.joins(:determinations)
      .where('determinations.updated_at >= ?', Time.now.beginning_of_week)
      .group('claims.id')
    # @context.claims.any_authorised
    #   .joins(:determinations)
    #   .where('determinations.created_at = (SELECT MAX(d.created_at) FROM "determinations" d WHERE d."claim_id" = "claims"."id")') #latest determination
    #   .where('determinations.updated_at >= ?', Time.now.beginning_of_week)
  end

  def total_outstanding_claim_value
    outstanding_claims.map { |c| c.total + c.vat_amount }.sum
  end

  def total_authorised_claim_value
    authorised_claims.map { |c| c.amount_assessed }.sum
  end
end
