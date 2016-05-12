class Fee::TransferFeeValidator < Fee::BaseFeeValidator

  def self.fields
    [
      :amount
    ]
  end

  def self.mandatory_fields
   [ :claim, :fee_type ]
  end

  def validate_amount
    validate_presence(:amount,'blank')
    validate_float_numericality(:amount,0.01,nil,'numericality')
  end

end
