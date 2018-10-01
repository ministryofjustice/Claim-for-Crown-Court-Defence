class ExpenseValidator < BaseValidator
  def self.fields
    %i[expense_type distance calculated_distance hours location location_type date
       reason_id reason_text mileage_rate_id amount vat_amount]
  end

  def self.mandatory_fields
    %i[claim]
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

  def validate_location_type
    return unless @record.location_type.present?
    add_error(:location_type, 'invalid') unless Establishment::CATEGORIES.include?(@record.location_type)
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
    if @record.car_travel? || @record.bike_travel?
      validate_presence_and_numericality(:distance, minimum: 0.1)
    else
      validate_absence(:distance, 'invalid')
    end
  end

  def validate_calculated_distance
    return unless @record.car_travel? && @record.calculated_distance.present?
    validate_presence_and_numericality(:calculated_distance, minimum: 0.1)
  end

  def validate_mileage_rate_id
    if @record.car_travel? || @record.bike_travel?
      validate_presence(:mileage_rate_id, 'blank')
      unless @record.mileage_rate_id.nil?
        add_error(:mileage_rate_id, 'invalid') if car_travel_missing_milage_rates || bike_travel_missing_milage_rates
      end
    else
      validate_absence(:mileage_rate_id, 'invalid')
    end
  end

  def validate_date
    validate_presence(:date, 'blank')
    validate_on_or_before(Date.today, :date, 'future')
    validate_on_or_after(@record.claim.try(:earliest_representation_order_date),
                         :date, 'check_not_earlier_than_rep_order')
  end

  def validate_hours
    if @record.travel_time?
      validate_presence_and_numericality(:hours, minimum: 0.1)
      validate_two_decimals(:hours) if @record.errors[:hours].empty?
    else
      validate_absence(:hours, 'invalid')
    end
  end

  def car_travel_missing_milage_rates
    @record.car_travel? && !@record.mileage_rate_id.in?(Expense::CAR_MILEAGE_RATES.keys)
  end

  def bike_travel_missing_milage_rates
    @record.bike_travel? && !@record.mileage_rate_id.in?(Expense::BIKE_MILEAGE_RATES.keys)
  end
end
