class FeeValidator < BaseClaimValidator

  def self.fields
    [ :fee_type, :quantity, :amount ]
  end

  private

  def validate_fee_type
    validate_presence(:fee_type, 'blank')
  end

  def validate_quantity
    @actual_trial_length = @record.try(:claim).try(:actual_trial_length) || 0

    case @record.fee_type.try(:code)
      when 'BAF'
        validate_basic_fee_quantity
      when 'DAF'
        validate_daily_attendance_3_40_quantity
      when 'DAH'
        validate_daily_attendance_41_50_quantity
      when 'DAJ'
        validate_daily_attendance_50_plus_quantity
      when 'PCM'
        validate_plea_and_case_management_hearing
    end

    validate_any_quantity

  end

  def validate_basic_fee_quantity
    if @record.claim.case_type.try(:is_fixed_fee?)
      validate_numericality(:quantity, 0, 0, 'You cannot claim a basic fee for this case type')
    else
      validate_numericality(:quantity, 1, 1, 'baf_qty1')
    end
  end

  def validate_daily_attendance_3_40_quantity
    return if @record.quantity == 0
    if @actual_trial_length < 3
      add_error(:quantity, 'daf_qty_mismatch')
    elsif @record.quantity > @actual_trial_length - 2
      add_error(:quantity, 'daf_qty_mismatch')
    elsif @record.quantity > 37
      add_error(:quantity, 'daf_qty_mismatch')
    end
  end

  def validate_daily_attendance_41_50_quantity
    return if @record.quantity == 0
    if @actual_trial_length < 41
      add_error(:quantity, 'dah_qty_mismatch')
    elsif @record.quantity > @actual_trial_length - 40
      add_error(:quantity, 'dah_qty_mismatch')
    elsif @record.quantity > 10
      add_error(:quantity, 'dah_qty_mismatch')
    end
  end

  def validate_daily_attendance_50_plus_quantity
    return if @record.quantity == 0
    if @actual_trial_length < 50
      add_error(:quantity, 'daj_qty_mismatch')
    elsif @record.quantity > @actual_trial_length - 50
      add_error(:quantity, 'daj_qty_mismatch')
    end
  end

  def validate_plea_and_case_management_hearing
    if @record.claim.case_type.try(:allow_pcmh_fee_type?)
      add_error(:quantity, 'pcm_invalid') if @record.quantity > 3
    else
      add_error(:quantity, 'pcm_invalid') unless (@record.quantity == 0 || @record.quantity.blank?)
    end
  end

  def validate_any_quantity
    add_error(:quantity, 'invalid') if @record.quantity < 0 || @record.quantity > 100
  end

  def validate_amount
    case_type = @record.fee_type.try(:code)
    case case_type
      when 'BAF'
        validate_baf_amount
      when "DAF", "DAH", "DAJ", "SAF", "PCM", "CAV", "NDR", "NOC", "NPW", "PPE"
        validate_non_baf_basic_fee_amount(case_type)
      else
        validate_misc_and_fixed_fee_amount
    end
  end

  def validate_baf_amount
    unless @record.claim.case_type.try(:is_fixed_fee?)
      add_error(:amount, 'baf_invalid') if @record.amount < 1
    end
  end

  def validate_misc_and_fixed_fee_amount
    if @record.quantity > 0 && @record.amount <= 0
      add_error(:amount, 'invalid')
    elsif @record.quantity <= 0 && @record.amount > 0
      add_error(:quantity, 'invalid')
    end
  end

  def validate_non_baf_basic_fee_amount(case_type)
    if @record.quantity > 0
      add_error(:amount, "#{case_type.downcase}_zero") if @record.amount < 1
    else
      add_error(:amount, "#{case_type.downcase}_invalid") if @record.amount != 0
    end
  end

end

