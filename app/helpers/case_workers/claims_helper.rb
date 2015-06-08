module CaseWorkers::ClaimsHelper
  def current_claims_count
    current_user.claims.allocated.count
  end

  def completed_claims_count
    current_user.claims.completed.count
  end
end
