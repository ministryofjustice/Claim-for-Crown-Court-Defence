class ClaimReporter
  def authorised_in_full
    claims = Claim.non_draft
    authorised_claims_this_month = claims.where{ authorised_at >= Time.now.beginning_of_month }.authorised

    claims_percentage(authorised_claims_this_month, claims)
  end

  def authorised_in_part
    claims = Claim.non_draft
    part_authorised_claims_this_month = claims.where{ authorised_at >= Time.now.beginning_of_month }.part_authorised

    claims_percentage(part_authorised_claims_this_month, claims)
  end

  def rejected
    claims = Claim.non_draft
    transitions = ClaimStateTransition.where{ (to == 'rejected') & (created_at >= Time.now.beginning_of_month) }
    rejected_claims_this_month = transitions.map(&:claim).uniq

    claims_percentage(rejected_claims_this_month, claims)
  end

  def outstanding
    Claim.where(state: %w( allocated submitted redetermination )).order(submitted_at: :asc)
  end

  def oldest_outstanding
    outstanding.first
  end

  def completion_rate
    intentions = ClaimIntention.where{ created_at >= 16.weeks.ago }
    claims = Claim.non_draft.where{ created_at >= 16.weeks.ago }

    completed = claims.map(&:form_id) & intentions.map(&:form_id)

    claims_percentage(completed, intentions)
  end

  private

  def claims_percentage(percentage_claims, all_claims)
    return 0.0 if percentage_claims.none? && all_claims.none?

    (percentage_claims.count.to_f / all_claims.count.to_f) * 100
  end
end
