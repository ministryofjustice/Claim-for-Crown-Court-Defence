class Fee::WarrantFeeValidator < Fee::BaseFeeValidator

  private

  def validate_warrant_issued_date
    validate_presence(:warrant_issued_date, 'blank')
    validate_not_after(Date.today, :warrant_issued_date, 'invalid') unless @record.warrant_issued_date.nil?
  end

  def validate_warrant_executed_date
    validate_not_before(@record.warrant_issued_date, :warrant_executed_date, 'warrant_executed_before_issued')
    validate_not_after(Date.today, :warrant_executed_date, 'invalid')
  end

end

