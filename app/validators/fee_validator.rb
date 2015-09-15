class FeeValidator < BaseClaimValidator

  private

  def self.fields
    [ :fee_type, :quantity, :amount, :dates_attended ]
  end

  def validate_fee_type
    validate_presence(:fee_type, "Fee type cannot be blank") 
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
    else
      validate_quantity_for_everything_else

    end
  end




  def validate_basic_fee_quantity
    if @record.claim.case_type.is_fixed_fee?
      validate_numericality(:quantity, 0, 0, 'You cannot claim a basic fee for this case type')
    else  
      validate_numericality(:quantity, 1, 1, 'Quantity for basic fee: only one basic fee can be claimed per case')
    end
  end

  def validate_daily_attendance_3_40_quantity
    return if @record.quantity == 0
    if @actual_trial_length < 3
      add_error(:quantity, 'Quantity for Daily attendance fee (3 to 40) does not correspond with the actual trial length') 
    elsif @record.quantity > @actual_trial_length - 2
      add_error(:quantity, 'Quantity for Daily attendance fee (3 to 40) does not correspond with the actual trial length')
    elsif @record.quantity > 37
      add_error(:quantity, 'Quantity for Daily attendance fee (3 to 40) does not correspond with the actual trial length')
    end
  end


  def validate_daily_attendance_41_50_quantity
    return if @record.quantity == 0
    if @actual_trial_length < 41
      add_error(:quantity, 'Quantity for Daily attendance fee (41 to 50) does not correspond with the actual trial length')
    elsif @record.quantity > @actual_trial_length - 40
      add_error(:quantity, 'Quantity for Daily attendance fee (41 to 50) does not correspond with the actual trial length')
    elsif @record.quantity > 10
      add_error(:quantity, 'Quantity for Daily attendance fee (41 to 50) does not correspond with the actual trial length')
    end
  end


  def validate_daily_attendance_50_plus_quantity
    return if @record.quantity == 0
    if @actual_trial_length < 50
      add_error(:quantity, 'Quantity for Daily attendance fee (51+) does not correspond with the actual trial length')
    elsif @record.quantity > @actual_trial_length - 50
      add_error(:quantity, 'Quantity for Daily attendance fee (51+) does not correspond with the actual trial length')
    end
  end


  def validate_plea_and_case_management_hearing
    if @record.claim.case_type.allow_pcmh_fee_type?
      if @record.quantity < 0
        add_error(:quantity, 'Quantity for fee cannot be negative')
      elsif @record.quantity == 0
        add_error(:quantity, 'You must enter a quantity between 1 and 3 for plea and case management hearings for this case type')
      elsif @record.quantity > 3
        add_error(:quantity, 'Quanity for plea and case management hearing cannot be greater than 3')
      end
    else
      add_error(:quantity, 'PCMH Fees quantity must be zero or blank for this case type') unless (@record.quantity == 0 || @record.quantity.blank?)
    end
  end


  def validate_quantity_for_everything_else
    add_error(:quantity, 'Fee quanity cannot be negative') if @record.quantity < 0
  end


  def validate_amount
    if @record.amount < 0
      add_error(:amount, 'Fee amount cannot be negative')
    elsif @record.quantity > 0 && @record.amount == 0
      add_error(:amount, 'Fee amount cannot be zero or blank if a fee quantity has been specified, please enter the relevant amount')
    elsif @record.quantity == 0 && @record.amount > 0
      add_error(:amount, 'Fee amounts cannot be specified if the fee quanitity is zero')
    #elsif @record.amount.to_i != @record.amount
    #  add_error(:amount, 'Fee amount must be whole numbers only')
    end
    if @record.fee_type
      unless @record.fee_type.max_amount.nil?
        add_error(:amount, "Fee amount exceeds maximum permitted (#{@record.fee_type.pretty_max_amount}) for this fee type") if @record.amount > @record.fee_type.max_amount
      end
    end
  end

 

  def validate_dates_attended
  end


end

