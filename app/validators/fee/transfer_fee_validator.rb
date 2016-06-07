class Fee::TransferFeeValidator < Fee::BaseFeeValidator
  def validate_amount
    validate_presence(:amount, 'blank')
    validate_float_numericality(:amount, 0.01, nil, 'numericality')
  end
end
