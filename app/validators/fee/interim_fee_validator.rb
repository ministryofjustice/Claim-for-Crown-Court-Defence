class Fee::InterimFeeValidator < Fee::BaseFeeValidator

  def self.mandatory_fields
   [ :claim, :disbursement_type ]
  end


  def validate_disbursement_type
    @record.is_warrant? ? validate_absence(:disbursement_type, 'present') : validate_presence(:disbursement_type, 'blank')
  end

  def validate_quantity
    if @record.is_disbursement? || @record.is_warrant?
      validate_absence_or_zero(:quantity, 'present')
    else
      validate_presence(:quantity, 'blank')
    end
  end

  def validate_amount
    if @record.is_disbursement? || @record.is_warrant?
      validate_absence_or_zero(:amount, 'present')
    else
      validate_presence(:amount, 'blank')
    end
  end

  def validate_rate
    validate_absence_or_zero(:rate, 'present')
  end



end