module CaseWorkers::ClaimsHelper
  def current_claims_count
    current_user.claims.caseworker_dashboard_under_assessment.count
  end

  def completed_claims_count
    current_user.claims.caseworker_dashboard_completed.count
  end

  def allocated_claims_count
    Claim.caseworker_dashboard_under_assessment.count
  end

  def unallocated_claims_count
    Claim.submitted.count # doesn't include appealed claims
  end
end
