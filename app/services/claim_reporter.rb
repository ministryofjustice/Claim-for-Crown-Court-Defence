class ClaimReporter
  def authorised_in_full
    non_draft_claims_this_month = Claim.non_draft.where{ created_at >= Time.now.beginning_of_month }
    authorised_claims_this_month = non_draft_claims_this_month.authorised

    claims_percentage(authorised_claims_this_month, non_draft_claims_this_month)
  end

  def authorised_in_part
    non_draft_claims_this_month = Claim.non_draft.where{ created_at >= Time.now.beginning_of_month }
    part_authorised_claims_this_month = non_draft_claims_this_month.part_authorised

    claims_percentage(part_authorised_claims_this_month, non_draft_claims_this_month)
  end

  def rejected
    non_draft_claims_this_month = Claim.non_draft.where{ created_at >= Time.now.beginning_of_month }
    rejected_claims_this_month = non_draft_claims_this_month.rejected

    claims_percentage(rejected_claims_this_month, non_draft_claims_this_month)
  end

  private

  def claims_percentage(percentage_claims, all_claims)
    (percentage_claims.count.to_f / all_claims.count.to_f) * 100
  end
end
