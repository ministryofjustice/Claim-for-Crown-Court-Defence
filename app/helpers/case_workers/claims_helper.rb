module CaseWorkers::ClaimsHelper
  def current_claims_count
    current_user.claims.allocated.count
  end

  def completed_claims_count
    current_user.claims.completed.count
  end

  def allocated_claims_count
    Claim.allocated.count
  end

  def unallocated_claims_count
    Claim.submitted.count
  end
end
