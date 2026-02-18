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

  def not_first_claim?
    (claim_ids.index(@claim.id) + 1) != 1
  end

  def not_last_claim?
    (claim_ids.index(@claim.id) + 1) != claim_count.to_i
  end

  def last_claim?
    (claim_ids.index(@claim.id) + 1) == claim_count.to_i
  end

  def next_claim_link
    case_workers_claim_path(claim_ids[claim_ids.index(@claim.id) + 1], sort: sort_column, direction: sort_direction)
  end  

  def previous_claim_link
    case_workers_claim_path(claim_ids[claim_ids.index(@claim.id) - 1], sort: sort_column, direction: sort_direction)
  end  

  def claim_ids
    @claim_ids ||= current_user.claims.allocated.order(sql_sort_column => sql_sort_direction).pluck(:id)
  end

  def claim_count
    @claim_count ||= claim_ids.count
  end

  def sql_sort_column
    {
      # 'type' => '???',
      'case_number' => 'case_number',
      # 'advocate' => '???',
      # 'total_inc_vat' => '???',
      # 'case_type' => '???',
      'last_submitted_at' => 'last_submitted_at'
    }[sort_column] || 'last_submitted_at'
  end

  def sql_sort_direction
    %w[asc desc].include?(sort_direction) ? sort_direction : 'desc'
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
