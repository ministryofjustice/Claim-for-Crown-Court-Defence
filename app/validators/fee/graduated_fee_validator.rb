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

  def validate_single_attendance_date
    validate_presence(:date, :blank)
    validate_on_or_after(@record.claim.try(:earliest_representation_order_date),
                         :date,
                         :too_long_before_earliest_reporder)
    validate_on_or_after(Settings.earliest_permitted_date, :date, :check_not_too_far_in_past)
    validate_not_in_future(:date)
  end

  def validate_quantity
    validate_numericality(:quantity, :numericality, 0, 99_999)
  end

  def validate_amount
    validate_presence_and_numericality_govuk_formbuilder(:amount, minimum: 0.1)
  end

  def validate_date
    validate_single_attendance_date
  end
end
