class Fee::GraduatedFeeValidator < Fee::BaseFeeValidator
  def self.fields
    %i[
      quantity
      date
    ] + super
  end

  def self.mandatory_fields
    %i[claim fee_type]
  end

  private

  def validate_claim
    super
    return unless @record.claim&.final?
    add_error(:claim, :incompatible_case_type) if @record.claim.case_type&.is_fixed_fee?
  end

  def validate_quantity
    validate_numericality(:quantity, 'numericality', 0, 99_999)
  end

  def validate_amount
    validate_presence_and_numericality(:amount, minimum: 0.1)
  end

  def validate_date
    validate_single_attendance_date
  end
end
