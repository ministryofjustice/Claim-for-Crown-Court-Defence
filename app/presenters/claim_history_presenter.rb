class ClaimHistoryPresenter < BasePresenter
  presents :claim

  def history_items_by_date
    unique_formatted_dates.each_with_object({}) do |date_string, hash|
      arr = select_by_date_string(messages, date_string) +
            select_by_date_string(state_transitions, date_string) +
            select_by_date_string(assessments, date_string) +
            select_by_date_string(redetermination_versions, date_string)
      hash[date_string] = arr.flatten.sort_by(&:created_at) if arr.any?
    end
  end

  private

  def unique_formatted_dates
    unique_sorted_dates.map { |d| d.strftime(Settings.date_format) }.uniq
  end

  def unique_sorted_dates
    (message_dates + state_transition_dates + assessment_dates + redetermination_dates).compact.uniq.sort
  end

  def message_dates
    messages.map(&:created_at)
  end

  def state_transitions
    claim_state_transitions.where.not(to: ['draft'])
  end

  def state_transition_dates
    state_transitions.map(&:created_at)
  end

  def assessment_dates
    assessments.map(&:created_at)
  end

  def redetermination_dates
    redetermination_versions.map(&:created_at)
  end

  def messages
    claim.messages.where('created_at IS NOT NULL').order(created_at: :asc)
  end

  def assessments
    claim.assessment.versions.order(created_at: :asc)
  end

  def redetermination_versions
    all_versions_of_all_redeterminations = []
    claim.redeterminations.each do |redetermination|
      all_versions_of_all_redeterminations << redetermination.versions.order(created_at: :asc)
    end
    all_versions_of_all_redeterminations.flatten
  end

  def select_by_date_string(collection, date_string)
    collection.select { |e| e.created_at.strftime(Settings.date_format) == date_string }
  end
end
