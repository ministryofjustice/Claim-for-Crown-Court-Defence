module Fee
  class WarrantFeeValidator < Fee::BaseFeeValidator
    MINIMUM_PERIOD_SINCE_ISSUED = 3.months

    def validate_warrant_issued_date
      validate_presence(:warrant_issued_date, :blank)
      validate_on_or_after(Settings.earliest_permitted_date, :warrant_issued_date, :check_not_too_far_in_past)
      return if @record.warrant_issued_date.nil?
      validate_not_in_future(:warrant_issued_date)
      unless allow_future_dates
        validate_on_or_before(MINIMUM_PERIOD_SINCE_ISSUED.ago, :warrant_issued_date,
                              :on_or_before)
      end
      check_date = @record.claim&.earliest_representation_order&.representation_order_date
      validate_on_or_after(check_date, :warrant_issued_date, :check_on_or_after_earliest_representation_order)
    end

    def validate_warrant_executed_date
      validate_on_or_after(@record.warrant_issued_date, :warrant_executed_date, :warrant_executed_before_issued)
      validate_on_or_after(Settings.earliest_permitted_date, :warrant_executed_date, :check_not_too_far_in_past)
      return if @record.warrant_executed_date.nil?
      validate_not_in_future(:warrant_executed_date)
    end

    def validate_amount
      validate_presence_and_numericality_govuk_formbuilder(:amount, minimum: 0.1)
    end
  end
end
