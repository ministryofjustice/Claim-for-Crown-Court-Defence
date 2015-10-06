class ClaimHistoryPresenter < BasePresenter
  presents :claim

  def history_and_messages
    unique_formatted_dates.inject({}) do |hash, date_string|
      arr = select_by_date_string(versions, date_string) + select_by_date_string(messages, date_string) + select_by_date_string(assessments, date_string)
      hash[date_string] = arr.flatten.sort_by { |e| e.created_at } if arr.any?
      hash
    end
  end

  private

  def unique_formatted_dates
    unique_sorted_dates.map { |d| d.strftime(Settings.date_format) }.uniq
  end

  def unique_sorted_dates
    (message_dates + version_dates + assessment_dates).compact.uniq.sort
  end

  def message_dates
    messages.map(&:created_at)
  end

  def version_dates
    versions.map(&:created_at)
  end

  def assessment_dates
    assessments.map(&:created_at)
  end

  def messages
    claim.messages.where('created_at IS NOT NULL').order(created_at: :asc)
  end

  def versions
    claim.versions.order(created_at: :asc)
  end

  def assessments
    claim.assessment.versions(created_at: :asc)
  end

  def select_by_date_string(collection, date_string)
    collection.select { |e| e.created_at.strftime(Settings.date_format) == date_string }
  end
end
