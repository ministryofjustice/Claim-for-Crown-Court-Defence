class ExpenseV2Validator < BaseValidator

  def self.fields
    [
      :expense_type,
      :location,
      :amount,
      :reason_id,
      :reason_text,
      :distance,
      :mileage_rate_id,
      :date,
      :hours
    ]
  end

  def self.mandatory_fields
    [:claim, :amount, :expense_type]
  end

  private

  def validate_claim
    validate_presence(:claim, 'blank')
  end

  def validate_expense_type
    validate_presence(:expense_type, 'blank')
  end

  def validate_amount
    validate_presence(:amount, 'blank')
  end

  def validate_location
    if @record.parking?
      validate_absence(:location, 'invalid')
    else
      validate_presence(:location, 'blank')
    end
  end

  def validate_amount
    validate_presence(:amount, 'blank')
  end

  def validate_reason_id
    if @record.reason_id.nil?
      add_error(:reason_id, 'blank')
    else
      add_error(:reason_id, 'invalid') unless @record.reason_id.in?(@record.expense_reasons.map(&:id))
    end
  end

  def validate_reason_text
    if @record.expense_reason_other?
      validate_presence(:reason_text, 'blank_for_other')
    else
      validate_absence(:reason_text, 'invalid')
    end
  end

  def validate_distance
    if @record.car_travel? || @record.train?
      validate_presence(:distance, 'blank')
      validate_numericality(:distance, 1, nil, 'zero')
    else
      validate_absence(:distance, 'invalid')
    end
  end

  def validate_mileage_rate_id
    if @record.car_travel?
      validate_presence(:mileage_rate_id, 'blank')
      unless @record.mileage_rate_id.nil?
        add_error(:mileage_rate_id, 'invalid') unless @record.mileage_rate_id.in?(Expense::MILEAGE_RATES.keys)
      end
    else
      validate_absence(:mileage_rate_id, 'invalid')
    end
  end

  def validate_date
    validate_presence(:date, 'blank')
    unless @record.date.blank?
      add_error(:date, 'future') if @record.date > Date.today
    end
  end

  def validate_hours
    if @record.travel_time?
      validate_presence(:hours, 'blank')
      unless @record.hours.blank?
        add_error(:hours, 'zero_or_negative') if @record.hours < 1
      end
    else
      validate_absence(:hours, 'invalid')
    end
  end
end
