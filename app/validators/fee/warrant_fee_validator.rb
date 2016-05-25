class Fee::WarrantFeeValidator < Fee::BaseFeeValidator

  def self.fields
    [ :amount ]
  end

  private

  def validate_warrant_issued_date
    validate_presence(:warrant_issued_date, 'blank')
    validate_not_before(Settings.earliest_permitted_date, :warrant_issued_date, 'check_not_too_far_in_past')
    validate_not_after(Date.today, :warrant_issued_date, 'check_not_in_future') unless @record.warrant_issued_date.nil?
  end

  def validate_warrant_executed_date
    validate_not_before(@record.warrant_issued_date, :warrant_executed_date, 'warrant_executed_before_issued')
    validate_not_before(Settings.earliest_permitted_date, :warrant_executed_date, 'check_not_too_far_in_past')
    validate_not_after(Date.today, :warrant_executed_date, 'check_not_in_future') unless @record.warrant_executed_date.nil?
  end

  def validate_amount
    validate_presence(:amount, 'blank')
    validate_float_numericality(:amount, 0.01, nil, 'numericality')
  end

end
