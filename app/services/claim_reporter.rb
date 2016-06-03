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
    intentions_form_id = ClaimIntention.where{ created_at >= 16.weeks.ago }.pluck(:form_id)
    claims_form_id = non_draft_claims.where{ created_at >= 16.weeks.ago }.pluck(:form_id)

    intentions = intentions_form_id.size
    completed = (claims_form_id & intentions_form_id).size

    claims_percentage(completed, intentions)
  end

  def processing_times
    claims_map = processed_claims.where{ created_at >= 16.weeks.ago }.uniq.pluck(:id, :original_submission_date).to_h
    claims_states = ClaimStateTransition.where(claim_id: claims_map.keys).order(created_at: :desc).pluck(:claim_id, :created_at)

    timings = claims_states.map do |(claim_id, created_at)|
      next unless claims_map.key?(claim_id)

      processed_timestamp = created_at
      submitted_timestamp = claims_map.delete(claim_id)

      (processed_timestamp - submitted_timestamp)
    end

    timings.compact
  end

  def average_processing_time
    average_processing_time = calculate_average(processing_times)
    average_processing_time.nan? ? 0.0 : average_processing_time
  end

  def average_processing_time_in_words
    distance_of_time_in_words(Time.now, Time.now - average_processing_time)
  end

  private

  def calculate_average(collection)
    collection.sum.to_f / collection.size
  end

  def processed_claims
    Claim::BaseClaim.caseworker_dashboard_completed
  end

  def non_draft_claims
    Claim::BaseClaim.non_draft
  end

  def claims_percentage(subset_count, all_count)
    return 0.0 if subset_count.zero? && all_count.zero?
    (subset_count.to_f / all_count.to_f) * 100
  end
end
