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

  # def calculate_claims_decided_this_month
  #   if @decided_claims.nil?
  #     @decided_claims = {}
  #     total_claims = 0
  #     [:authorised, :part_authorised, :rejected, :refused].each do |state|
  #       @decided_claims[state] = claims_decided_this_month(state)
  #       total_claims += @decided_claims[:state]
  #     end
  #    @decided_claims[:total] = total_claims
  #   end
  #   @decided_claims
  # end

  # def claims_decided_this_month(state)
  #   ClaimStateTransition.decided_this_month
  # end

  # def decided_claims_percentage(state)
  #   calculate_claims_decided_this_month[state].to_f / calculate_claims_decided_this_month[:total].to_f
  # end

  # def non_draft_claims
  #   Claim::BaseClaim.active.non_draft
  # end

  def claims_percentage(subset_count, all_count)
    return 0.0 if subset_count.zero? && all_count.zero?
    (subset_count.to_f / all_count.to_f) * 100
  end
end
