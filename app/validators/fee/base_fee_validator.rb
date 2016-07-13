class Fee::BaseFeeValidator < BaseValidator

  def self.fields
    [
      :amount,
      :warrant_issued_date,
      :warrant_executed_date
    ]
  end

  def self.mandatory_fields
    [:claim, :fee_type]
  end

private

  def validate_warrant_issued_date
    validate_absence(:warrant_issued_date, 'present')
  end

  def validate_warrant_executed_date
    validate_absence(:warrant_executed_date, 'present')
  end

  def validate_claim
    validate_presence(:claim, 'blank')
  end

  def validate_fee_type
    validate_presence(:fee_type, 'blank')
  end

  def validate_date
    validate_absence(:date, 'present')
  end

  def validate_quantity
    @actual_trial_length = trial_length

    case fee_code
      when 'BAF'
        validate_baf_quantity
      when 'DAF'
        validate_daily_attendance_3_40_quantity
      when 'DAH'
        validate_daily_attendance_41_50_quantity
      when 'DAJ'
        validate_daily_attendance_51_plus_quantity
      when 'PCM'
        validate_pcm_quantity
    end

    validate_any_quantity
  end

  def validate_baf_quantity
    validate_numericality(:quantity, 0, 1, 'baf_qty_numericality')
  end

  # cannot claim this fee if trial lasted less than 3 days
  # can only claim a maximum of 38 (or trial length after first 2 days deducted)
  def validate_daily_attendance_3_40_quantity
    return if @record.quantity == 0
    add_error(:quantity, 'daf_qty_mismatch') if daf_trial_length_combination_invalid(3, -2, 38)
  end

  # cannot claim this fee if trial lasted less than 41 days
  # can only claim a maximum of 10 (or trial length after first 40 days deducted)
  def validate_daily_attendance_41_50_quantity
    return if @record.quantity == 0
    add_error(:quantity, 'dah_qty_mismatch') if daf_trial_length_combination_invalid(41, -40, 10)
  end

  # cannot claim this fee if trial lasted less than 51 days
  # can only claim a maximum of trial length after first 50 days deducted
  def validate_daily_attendance_51_plus_quantity
    return if @record.quantity == 0
    add_error(:quantity, 'daj_qty_mismatch') if daf_trial_length_combination_invalid(51, -50, nil)
  end

  def validate_pcm_quantity
    if @record.claim.case_type.try(:allow_pcmh_fee_type?)
      add_error(:quantity, 'pcm_numericality') if @record.quantity > 3
    else
      add_error(:quantity, 'pcm_not_applicable') unless @record.quantity == 0 || @record.quantity.blank?
    end
  end

  def validate_any_quantity
    validate_integer_decimal
    add_error(:quantity, 'invalid') if @record.quantity < 0 || @record.quantity > 99999
  end

  def validate_integer_decimal
    return if @record.fee_type.nil? || @record.quantity.nil?
    unless @record.quantity_is_decimal?
      add_error(:quantity, 'integer') unless @record.quantity.frac == 0.0
    end
  end

  def validate_rate
    # NOTE: this is to ensure we do not validate those fees for claims that have already been submitted
    #       and are before rate was re-introduced for advocate claim fees
    return unless @record.try(:claim).try(:editable?)

    code = fee_code
    if @record.calculated?
      validate_calculated_fee(code)
    else
      validate_uncalculated_fee(code)
    end
  end

  def validate_calculated_fee(code)
    case code
      when "BAF", "DAF", "DAH", "DAJ", "SAF", "PCM", "CAV", "NDR", "NOC"
        validate_basic_fee_rate(code)
      else
        validate_calculated_quantity_rate_combination
    end
  end

  def validate_uncalculated_fee(code)
    add_error(:rate, "#{code.downcase}_must_be_blank") if @record.rate > 0
  end

  # if one has a value and the other doesn't then we add error to the one that does NOT have a value
  def validate_calculated_quantity_rate_combination
    if @record.quantity > 0 && @record.rate <= 0
      add_error(:rate, 'invalid')
    elsif @record.quantity <= 0 && @record.rate > 0
      add_error(:quantity, 'invalid')
    end
  end

  # if one has a value and the other doesn't then we add error to the one that does NOT have a value
  # NOTE: we have specific error messages for basic fees
  def validate_basic_fee_rate(code)
    if @record.quantity > 0 && @record.rate <= 0
      add_error(:rate, "invalid")
    elsif @record.quantity <= 0 && @record.rate > 0
      add_error(:quantity, "#{code.downcase}_invalid")
    end
  end

  def validate_amount
    return if fee_code.nil?

    add_error(:amount, "#{fee_code.downcase}_invalid") if @record.amount < 0 || @record.amount > Settings.max_item_amount

    if !@record.calculated?
      if @record.quantity <= 0 && @record.amount > 0
        add_error(:quantity, "#{fee_code.downcase}_invalid")
      end
    end
  end

  def validate_single_attendance_date
    validate_presence(:date, 'blank')
    validate_not_before(@record.claim.try(:earliest_representation_order).try(:representation_order_date), :date, 'not_before_earliest_representation_order_date')
    validate_not_before(Settings.earliest_permitted_date, :date, 'check_not_too_far_in_past')
    validate_not_after(Date.today, :date, 'check_not_in_future')
  end

  # local helpers
  # ---------------------

  def fee_code
    @record.fee_type.try(:code)
  end

  def trial_length
    if @record.claim.try(:case_type).try(:requires_retrial_dates?)
      @record.try(:claim).try(:retrial_actual_length) || 0
    else
      @record.try(:claim).try(:actual_trial_length) || 0
    end
  end

  def daf_trial_length_combination_invalid(lower_bound, trial_length_modifier, max_quantity=nil)
    raise ArgumentError if trial_length_modifier > 0
    return false if daf_retrial_combo_ignorable

    max_quantity = infinity if max_quantity.blank?
    @actual_trial_length < lower_bound || @record.quantity > [max_quantity, @actual_trial_length + trial_length_modifier].min
  end

  # This is required for retrial claims created prior to retrial fields being added.
  def daf_retrial_combo_ignorable
    @record.claim.case_type.requires_retrial_dates? && !@record.claim.editable? rescue false
  end

end
