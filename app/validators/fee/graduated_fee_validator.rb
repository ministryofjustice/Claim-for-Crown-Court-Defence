class Fee::GraduatedFeeValidator < Fee::BaseFeeValidator
  def self.fields
    [
      :quantity,
      :date
    ] + super
  end

  private

  def validate_claim
    super
    if @record.claim
      if @record.claim.final?
        add_error(:claim, 'Fixed fee invalid on non-fixed fee case types') if @record.claim.case_type.is_fixed_fee?
      end
    end
  end

  def self.mandatory_fields
    [:claim, :fee_type]
  end

  def validate_quantity
    validate_numericality(:quantity, 0, 99_999, 'numericality')
  end

  def validate_amount
    validate_presence_and_numericality(:amount, minimum: 0.1)
  end

  def validate_date
    validate_single_attendance_date
  end
end
