class Fee::MiscFeeValidator < Fee::BaseFeeValidator

  def self.fields
    [
      :quantity,
      :rate,
      :amount,
      :case_numbers
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

  def validate_case_numbers
    return if fee_code.nil?

    if case_uplift_fee?
      validate_presence(:case_numbers, 'blank')
      validate_each_case_number(:case_numbers, 'invalid')
    else
      validate_absence(:case_numbers, 'present')
    end
  end

  def validate_each_case_number(attribute, message)
    return if @record.__send__(attribute).blank?

    @record.__send__(attribute).split(',').each do |case_number|
      case_number.strip.match(CASE_NUMBER_PATTERN) || (add_error(attribute, message) && return)
    end
  end

  def run_base_fee_validators?
    !@record.claim.lgfs?
  end

  def case_uplift_fee?
    @record.fee_type.case_uplift?
  end
end