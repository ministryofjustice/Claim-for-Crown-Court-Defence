class Fee::InterimFeeValidator < Fee::BaseFeeValidator

  def self.fields
    [
      :quantity,
      :rate,
      :amount,
      :disbursements,
      :warrant
    ]
  end

  def self.mandatory_fields
   [ :claim, :fee_type ]
  end

  def validate_quantity
    if @record.is_disbursement? || @record.is_interim_warrant?
      validate_absence_or_zero(:quantity, 'present')
    else
      validate_any_quantity
    end
  end

  def validate_amount
    if @record.is_disbursement? || @record.is_interim_warrant?
      validate_absence_or_zero(:amount, 'present')
    else
      add_error(:amount, 'invalid') if @record.amount < 0.01
    end
  end

  def validate_rate
    validate_absence_or_zero(:rate, 'present')
  end

  def validate_disbursements
    if @record.is_disbursement?
      add_error(:disbursements, 'blank') if @record.claim.disbursements.empty?
    else
      add_error(:disbursements, 'present') if (@record.is_interim_warrant? && @record.claim.disbursements.any?)
    end
  end

  def validate_warrant
    if @record.is_interim_warrant?
      add_error(:warrant, 'blank') if @record.claim.warrant_fee.nil?
    else
      add_error(:warrant, 'present') if @record.claim.warrant_fee.present?
    end
  end
end