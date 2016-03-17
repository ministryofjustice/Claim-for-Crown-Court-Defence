class ExpenseV2Validator < BaseValidator

  def self.fields
    [
      :expense_type,
      :location,
      :quantity,
      :rate,
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
    [:claim]
  end

  private

  def validate_claim
    validate_presence(:claim, 'blank')
  end

  def validate_expense_type
    validate_presence(:expense_type, 'blank')
  end

  def validate_location
    if @record.parking?
      validate_absence(:location, 'invalid')
    else
      validate_presence(:location, 'blank')
    end
  end

  def validate_quantity
    validate_presence(:quantity, 'blank')
    validate_numericality(:quantity, 0, nil, 'numericality')
  end

  def validate_rate
    validate_presence(:rate, 'blank')
    validate_numericality(:rate, 0, nil, 'numericality')
  end

  def validate_amount
  end

  def validate_reason_id
    if @record.reason_id.nil?
      add_error(:reason_id, 'blank')
    else
      add_error(:reason_id, 'invalid') unless @record.reason_id.in?(@record.expense_reasons.map(&:id))
    end
  end

  def validate_reason_text
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
  end

  def validate_date
  end

  def validate_hours
  end



end
