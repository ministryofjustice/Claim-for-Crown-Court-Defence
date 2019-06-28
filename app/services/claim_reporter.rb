class ClaimReporter
  include ActionView::Helpers::DateHelper

  def completion_rate
    intentions_form_id = ClaimIntention.where(created_at: 16.weeks.ago..3.weeks.ago).pluck(:form_id)
    completed = Claim::BaseClaim
                .active
                .where.not(state: 'draft')
                .where(form_id: intentions_form_id)
                .where.not(last_submitted_at: nil)
                .size
    intentions = intentions_form_id.size

    claims_percentage(completed, intentions)
  end

  private

  def claims_percentage(subset_count, all_count)
    return 0.0 if subset_count.zero? && all_count.zero?
    subset_count.fdiv(all_count) * 100
  end
end
