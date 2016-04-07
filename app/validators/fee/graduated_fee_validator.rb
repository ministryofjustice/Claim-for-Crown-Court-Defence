class Fee::GraduatedFeeValidator < Fee::BaseFeeValidator
  def self.mandatory_fields
    super + [ :trial_timings ]
  end

  private

  def validate_trial_timings
    if @record.requires_trial_dates
      validate_presence(:first_day_of_trial, "blank")
      validate_presence(:actual_trial_length, "blank")
      validate_first_day_of_trial if @record.first_day_of_trial.present?
      validate_actual_trial_length
    else
      validate_absence(:first_day_of_trial, "present")
      validate_absence(:actual_trial_length, "present")
    end
  end

  def validate_first_day_of_trial
    return unless @record.first_day_of_trial.present?

    unless @record.first_day_of_trial < Time.now
      add_error(:first_day_of_trial, "in_past")
    end

    if (Time.now - @record.first_day_of_trial) > 5.years
      add_error(:first_day_of_trial, "since_5_years")
    end
  end

  def validate_actual_trial_length
    return unless  @record.actual_trial_length.present? && @record.first_day_of_trial.present?

    if (Time.now - @record.first_day_of_trial) < @record.actual_trial_length.days
      add_error(:actual_trial_length, "too_long")
    end
  end
end
