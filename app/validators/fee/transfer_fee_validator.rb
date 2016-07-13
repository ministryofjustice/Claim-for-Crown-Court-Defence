class Fee::TransferFeeValidator < Fee::BaseFeeValidator

  def validate_amount
    validate_presence_and_numericality(:amount, minimum: 0.1)
  end

end
