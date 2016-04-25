class Fee::WarrantFeeValidator < Fee::BaseFeeValidator

  def self.fields
    [ :amount ]
  end

  private

  def validate_warrant_issued_date
    validate_presence(:warrant_issued_date, 'blank')
    validate_not_after(Date.today, :warrant_issued_date, 'invalid') unless @record.warrant_issued_date.nil?
  end

  def validate_warrant_executed_date
    validate_not_before(@record.warrant_issued_date, :warrant_executed_date, 'warrant_executed_before_issued')
    validate_not_after(Date.today, :warrant_executed_date, 'invalid')
  end

  def validate_amount
    if validate_amount?
      validate_numericality(:amount, 0.01, nil, 'numericality')
    else
      validate_absence_or_zero(:amount, 'present')
    end
  end

  def validate_amount?
    @record.claim.interim? && @record.claim.interim_fee.try(:is_interim_warrant?)
  end
end
