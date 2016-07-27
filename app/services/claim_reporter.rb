class ClaimReporter
  include ActionView::Helpers::DateHelper

  def authorised_in_full
    claims = non_draft_claims.count
    authorised_claims_this_month = non_draft_claims.where{ authorised_at >= Time.now.beginning_of_month }.authorised.count

    {
      count: authorised_claims_this_month,
      percentage: claims_percentage(authorised_claims_this_month, claims)
    }
  end

  def authorised_in_part
    claims = non_draft_claims.count
    part_authorised_claims_this_month = non_draft_claims.where{ authorised_at >= Time.now.beginning_of_month }.part_authorised.count

    {
      count: part_authorised_claims_this_month,
      percentage: claims_percentage(part_authorised_claims_this_month, claims)
    }
  end

  def rejected
    claims = non_draft_claims.count
    rejected_claims_this_month = ClaimStateTransition.where{ (to == 'rejected') & (created_at >= Time.now.beginning_of_month) }.count('DISTINCT claim_id')

    {
      count: rejected_claims_this_month,
      percentage: claims_percentage(rejected_claims_this_month, claims)
    }
  end

  def completion_rate
    intentions_form_id = ClaimIntention.where(created_at: 16.weeks.ago..3.weeks.ago).pluck(:form_id)
    completed = Claim::BaseClaim.where.not(state: 'draft').where(form_id: intentions_form_id).where.not(last_submitted_at: nil).size
    intentions = intentions_form_id.size

    claims_percentage(completed, intentions)
  end

  private

  def non_draft_claims
    Claim::BaseClaim.non_draft
  end

  def claims_percentage(subset_count, all_count)
    return 0.0 if subset_count.zero? && all_count.zero?
    (subset_count.to_f / all_count.to_f) * 100
  end
end
