class DateAttendedValidator < BaseClaimValidator

  @@fields = [  :date, :date_to ]

  def self.fields
    @@fields
  end


  private

  # must be present
  # must not be in the future
  # must not be before 1st day of trial
  # must not be before 1st reporder date
  # must not be before the earliest_permitted_date
  def validate_date
    validate_presence(:date, "Date attended cannot be blank") 
    validate_not_before(@record.claim.first_day_of_trial, :date, "Date attended cannot be before first day of trial") if @record.attended_item_type != 'Expense'
    validate_not_before(@record.claim.earliest_representation_order.representation_order_date, :date, "Date attended cannot be before the date of the first representation order")
    validate_not_before(Settings.earliest_permitted_date, :date, "Date attended cannot be more than #{Settings.earliest_permitted_date_in_words}")
  end

  # must not be before DateAttended#date
  # must not be in the future
  def validate_date_to
    validate_not_before(@record.date, :date_to, "Date attended to cannot be before the date attended")
    validate_not_after(Date.today, :date_to, "Date attended to cannot be in the future")
  end

end