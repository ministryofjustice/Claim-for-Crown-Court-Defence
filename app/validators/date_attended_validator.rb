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
  # must not be before the earliest_permitted_date
  # CTSKF-1582 - remove the 2 year limit for date attended 
  # as we can find no evidence of this being a requirement in the original spec
  # and it is in conflict with requirement that date must not be before the earliest permitted date

  def validate_date
    validate_presence(:date, :blank)
    validate_on_or_after(Settings.earliest_permitted_date, :date, :not_before_earliest_permitted_date)
    validate_not_in_future(:date)
  end
end
