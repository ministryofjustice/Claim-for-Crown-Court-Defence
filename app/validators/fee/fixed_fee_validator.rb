class Fee::FixedFeeValidator < Fee::BaseFeeValidator

  def self.fields
    [
      :quantity,
      :rate,
      :amount,
      :sub_type
    ]
  end

  private

  def validate_quantity
    super if run_base_fee_validators?
  end

  def validate_rate
    super if run_base_fee_validators?
  end

  def validate_amount
    if run_base_fee_validators? || fee_code.nil?
      super
    else
      add_error(:amount, "#{fee_code.downcase}_invalid") if @record.amount < 0.01
    end
  end

  def validate_sub_type
    return if fee_code.nil?

    if @record.fee_type.children.any?
      validate_presence(:sub_type, 'blank')
      validate_inclusion(:sub_type, @record.fee_type.children, 'invalid')
    else
      validate_absence(:sub_type, 'present')
    end
  end

  def run_base_fee_validators?
    !@record.claim.lgfs?
  end
end