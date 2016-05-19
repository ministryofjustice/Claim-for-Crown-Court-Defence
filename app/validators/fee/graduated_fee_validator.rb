class Fee::GraduatedFeeValidator < Fee::BaseFeeValidator

  def self.fields
    [
      :quantity,
      :amount
    ]
  end

  def self.mandatory_fields
   [ :claim, :fee_type ]
  end

  def validate_quantity
    validate_presence(:quantity,'blank')
    validate_numericality(:quantity,1,99999,'numericality')
  end

  def validate_amount
    validate_presence(:amount,'blank')
    validate_float_numericality(:amount,0.01,nil,'numericality')
  end

end
