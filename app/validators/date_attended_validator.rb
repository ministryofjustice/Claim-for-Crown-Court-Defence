class DateAttendedValidator < BaseValidator
  def self.fields
    %i[
      date
    ]
  end

  private

  # must be present
  # must not be in the future
  # must not be before 1st day of trial
  # must not be earlier than 2 years before the first rep order date
  # must not be before the earliest_permitted_date
  def validate_date
    validate_presence(:date, :blank)
    if @record.earliest_date_before_reporder
      validate_on_or_after(@record.earliest_date_before_reporder - 2.years, :date, :too_long_before_earliest_reporder)
    end
    validate_on_or_after(Settings.earliest_permitted_date, :date, :not_before_earliest_permitted_date)
    validate_not_in_future(:date)
  end
end
