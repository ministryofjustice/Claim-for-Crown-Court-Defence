class Fee::InterimFeeValidator < Fee::BaseFeeValidator

  def self.fields
    [
      :quantity,
      :rate,
      :amount,
      :disbursements,
    ]
  end

  def validate_quantity
    if @record.is_disbursement? || @record.is_interim_warrant?
      validate_absence_or_zero(:quantity, 'present')
    else
      validate_presence(:quantity,'blank')
      validate_numericality(:quantity,1,nil,'numericality')
    end
  end

  def validate_amount
    if @record.is_disbursement?
      validate_absence_or_zero(:amount, 'present')
    else
      validate_presence(:amount,'blank')
      validate_float_numericality(:amount,0.01,nil,'numericality')
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

  def validate_warrant_issued_date
    return unless @record.is_interim_warrant?
    validate_presence(:warrant_issued_date, 'blank')
    validate_not_before(Settings.earliest_permitted_date, :warrant_issued_date, 'check_not_too_far_in_past')
    validate_not_after(Date.today, :warrant_issued_date, 'check_not_in_future')
  end

  def validate_warrant_executed_date
    return unless @record.is_interim_warrant?
    validate_not_before(@record.warrant_issued_date, :warrant_executed_date, 'warrant_executed_before_issued')
    validate_not_after(Date.today, :warrant_executed_date, 'check_not_in_future')
  end

end