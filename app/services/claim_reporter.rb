class ClaimReporter
  include ActionView::Helpers::DateHelper

  def authorised_in_full
    claims = Claim::BaseClaim.non_draft
    authorised_claims_this_month = claims.where{ authorised_at >= Time.now.beginning_of_month }.authorised

    {
      count: authorised_claims_this_month.count,
      percentage: claims_percentage(authorised_claims_this_month, claims)
    }
  end

  def authorised_in_part
    claims = Claim::BaseClaim.non_draft
    part_authorised_claims_this_month = claims.where{ authorised_at >= Time.now.beginning_of_month }.part_authorised

    {
      count: part_authorised_claims_this_month.count,
      percentage: claims_percentage(part_authorised_claims_this_month, claims)
    }
  end

  def rejected
    claims = Claim::BaseClaim.non_draft
    transitions = ClaimStateTransition.where{ (to == 'rejected') & (created_at >= Time.now.beginning_of_month) }
    rejected_claims_this_month = transitions.map(&:claim).uniq

    {
      count: rejected_claims_this_month.count,
      percentage: claims_percentage(rejected_claims_this_month, claims)
    }
  end

  def rejected_count
    rejected_claims = Claim::BaseClaim.where(state: 'rejected')
    rejected_claims.count
  end

  def outstanding
    Claim::BaseClaim.where(state: %w( allocated submitted redetermination )).order(original_submission_date: :asc)
  end

  def oldest_outstanding
    outstanding.first
  end

  def completion_rate
    intentions = ClaimIntention.where{ created_at >= 16.weeks.ago }
    claims = Claim::BaseClaim.non_draft.where{ created_at >= 16.weeks.ago }

    completed = claims.map(&:form_id) & intentions.map(&:form_id)

    claims_percentage(completed, intentions)
  end

  def processing_times
    processing_times = processed_claims.inject([]) do |times, claim|
      processed_timestamp = claim.claim_state_transitions.order(created_at: :asc).last.created_at
      submitted_timestamp = claim.original_submission_date
      times << (submitted_timestamp - processed_timestamp)
    end.sort
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
    collection.inject{ |sum, e| sum + e }.to_f / collection.size
  end

  def processed_claims
    Claim::BaseClaim.caseworker_dashboard_completed
  end

  def claims_percentage(percentage_claims, all_claims)
    return 0.0 if percentage_claims.none? && all_claims.none?

    (percentage_claims.count.to_f / all_claims.count.to_f) * 100
  end
end
