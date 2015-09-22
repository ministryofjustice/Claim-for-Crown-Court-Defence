class ClaimHistoryPresenter < BasePresenter
  presents :claim

  def history_and_messages
    unique_formatted_dates.inject({}) do |hash, date_string|
      arr = select_by_date_string(versions, date_string) + select_by_date_string(messages, date_string)
      hash[date_string] = arr.flatten.sort_by { |e| e.created_at } if arr.any?
      hash
    end
  end

  private

  def unique_formatted_dates
    unique_sorted_dates.map { |d| d.strftime(Settings.date_format) }.uniq
  end

  def unique_sorted_dates
    (messages.map(&:created_at) + versions.map(&:created_at)).compact.uniq.sort
  end

  def messages
    claim.messages.where('created_at IS NOT NULL').order(created_at: :asc)
  end

  def versions
    claim.versions.order(created_at: :asc)
  end

  def select_by_date_string(collection, date_string)
    collection.select { |e| e.created_at.strftime(Settings.date_format) == date_string }
  end
end
