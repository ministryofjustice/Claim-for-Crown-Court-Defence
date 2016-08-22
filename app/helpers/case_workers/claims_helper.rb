module CaseWorkers::ClaimsHelper
  def current_claims_count
    current_user.claims.caseworker_dashboard_under_assessment.count
  end

  def completed_claims_count
    if current_user.persona.admin?
      Claim::BaseClaim.active.caseworker_dashboard_completed.count
    else
      current_user.claims.caseworker_dashboard_completed.count
    end
  end

  def allocated_claims_count
    Claim::BaseClaim.active.caseworker_dashboard_under_assessment.count
  end

  def unallocated_claims_count
    Claim::BaseClaim.active.submitted_or_redetermination_or_awaiting_written_reasons.count
  end

  def claim_position_and_count
    "#{claim_ids.index(@claim.id) + 1} of #{claim_count}"
  end

  def last_claim?
    (claim_ids.index(@claim.id) + 1) == claim_count.to_i
  end

  def next_claim_link(text, options = {})
    link_to text, case_workers_claim_path(claim_ids[claim_ids.index(@claim.id) + 1]), options
  end

  def claim_ids
    session[:claim_ids]
  end

  def claim_count
    session[:claim_count]
  end
end
