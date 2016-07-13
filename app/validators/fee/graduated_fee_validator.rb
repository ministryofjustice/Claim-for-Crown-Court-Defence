class Fee::GraduatedFeeValidator < Fee::BaseFeeValidator

  def self.fields
    [
      :quantity,
      :date
    ] + super
  end

  def self.mandatory_fields
    [:claim, :fee_type]
  end

  def validate_quantity
    validate_presence(:quantity, 'blank')
    validate_numericality(:quantity, 1, 99999, 'numericality')
  end

  def validate_amount
    validate_presence_and_numericality(:amount, minimum: 0.1)
  end

  def validate_date
    validate_single_attendance_date
  end
end
