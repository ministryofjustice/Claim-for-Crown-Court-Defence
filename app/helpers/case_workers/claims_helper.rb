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

  def format_miscellaneous_fee_names(claim)
    claim.eligible_misc_fee_types.map do |fees|
      fees.description.split('(')[0].strip
    end.uniq
  end

  def cda_view_enabled?
    ENV['COURT_DATA_ADAPTOR_API_UID'].present? &&
      current_user_is_caseworker? &&
      current_user.persona.has_roles?('beta_tester')
  end
end
