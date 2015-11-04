class DateAttendedValidator < BaseClaimValidator

  def self.fields
    [ :date, :date_to ]
  end

  private

  # must be present
  # must not be in the future
  # must not be before 1st day of trial
  # must not be before 1st reporder date
  # must not be before the earliest_permitted_date
  def validate_date
    # if the date attended is associated to an basic fee but no basic fees require for that case type
    # or a fixed fee but no fixed fee required for that case type then do not bother validating it
    if @record.case_type.
      validate_presence(:date, 'blank')
      validate_not_before(@record.claim.first_day_of_trial, :date, 'not_before_first_day_of_trial') if @record.attended_item_type != 'Expense'
      validate_not_before(@record.try(:claim).try(:earliest_representation_order).try(:representation_order_date), :date, 'not_before_earliest_representation_order_date')
      validate_not_before(Settings.earliest_permitted_date, :date, 'not_before_earliest_permitted_date')
    end
  end

  # must not be before DateAttended#date
  # must not be in the future
  def validate_date_to
    validate_not_before(@record.date, :date_to, 'not_before_date_from')
    validate_not_after(Date.today, :date_to, 'not_after_today')
  end

end