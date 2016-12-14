class ExpenseV2Validator < BaseValidator

  def self.fields
    [
      :expense_type,
      :distance,
      :hours,
      :location,
      :date,
      :reason_id,
      :reason_text,
      :mileage_rate_id,
      :amount,
      :vat_amount
    ]
  end

  def self.mandatory_fields
    [
      :claim
    ]
  end

  private

  def validate_claim
    validate_presence(:claim, 'blank')
  end

  def validate_expense_type
    validate_presence(:expense_type, 'blank')
  end

  def validate_amount
    validate_presence_and_numericality(:amount, minimum: 0.1)
  end

  def validate_vat_amount
    validate_vat_numericality(:vat_amount, lower_than_field: :amount)
  end

  def validate_location
    if @record.parking?
      validate_absence(:location, 'invalid')
    else
      validate_presence(:location, 'blank')
    end
  end

  def validate_reason_id
    if @record.reason_id.nil?
      add_error(:reason_id, 'blank')
    else
      unless @record.expense_type.nil? || @record.reason_id.in?(@record.expense_reasons.map(&:id))
        add_error(:reason_id, 'invalid')
      end
    end
  end

  def validate_reason_text
    if @record.expense_reason_other?
      validate_presence(:reason_text, 'blank_for_other')
    elsif @record.reason_id.present? && @record.expense_type.present?
      validate_absence(:reason_text, 'invalid')
    end
  end

  def validate_distance
    if @record.car_travel?
      validate_presence_and_numericality(:distance, minimum: 0.1)
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
    validate_not_after(Date.today, :date, 'future')
    validate_not_before(Settings.earliest_permitted_date, :date, 'check_not_too_far_in_past')
  end

  def validate_hours
    if @record.travel_time?
      validate_presence_and_numericality(:hours, minimum: 0.1)
      validate_two_decimals(:hours) if @record.errors[:hours].empty?
    else
      validate_absence(:hours, 'invalid')
    end
  end



end
