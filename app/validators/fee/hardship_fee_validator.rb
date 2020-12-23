class Fee::HardshipFeeValidator < Fee::BaseFeeValidator
  def self.fields
    %i[
      quantity
    ] + super
  end

  def validate_amount
    validate_presence_and_numericality(:amount, minimum: 0.1)
  end

  # ppe
  def validate_quantity
    validate_presence_and_numericality(:quantity, minimum: 0)
  end
end
