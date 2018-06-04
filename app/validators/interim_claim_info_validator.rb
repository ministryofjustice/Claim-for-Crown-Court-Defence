class InterimClaimInfoValidator < BaseValidator
  def self.fields
    %i[warrant_issued_date warrant_executed_date]
  end

  def validate_warrant_issued_date
    return unless @record.warrant_fee_paid?
    validate_presence(:warrant_issued_date, 'blank')
    validate_on_or_after(Settings.earliest_permitted_date, :warrant_issued_date, 'check_not_too_far_in_past')
    return if @record.warrant_issued_date.nil?
    validate_on_or_before(Date.today, :warrant_issued_date, 'check_not_in_future')
  end

  def validate_warrant_executed_date
    return unless @record.warrant_fee_paid?
    validate_presence(:warrant_executed_date, 'blank')
    validate_on_or_after(@record.warrant_issued_date, :warrant_executed_date, 'warrant_executed_before_issued')
    validate_on_or_after(Settings.earliest_permitted_date, :warrant_executed_date, 'check_not_too_far_in_past')
    return if @record.warrant_executed_date.nil?
    validate_on_or_before(Date.today, :warrant_executed_date, 'check_not_in_future')
  end
end
