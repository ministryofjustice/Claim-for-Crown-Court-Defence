class Claim::InterimClaimValidator < Claim::BaseClaimValidator
  include Claim::LitigatorCommonValidations

  def self.fields_for_steps
    [
      [].unshift(first_step_common_validations),
      [
        :interim_fee,
        :first_day_of_trial,
        :estimated_trial_length,
        :trial_concluded_at,
        :retrial_started_at,
        :retrial_estimated_length,
        :effective_pcmh_date,
        :legal_aid_transfer_date,
        :total
      ]
    ]
  end

  private

  def validate_interim_fee
    add_error(:interim_fee, 'blank') if @record.interim_fee.nil?
  end

  def validate_first_day_of_trial
    if @record.interim_fee.try(:is_trial_start?)
      validate_presence(:first_day_of_trial, 'blank')
    else
      validate_absence(:first_day_of_trial, 'present')
    end
  end

  def validate_estimated_trial_length
    if @record.interim_fee.try(:is_trial_start?)
      validate_presence(:estimated_trial_length, 'blank')
      validate_numericality(:estimated_trial_length, 0, nil, 'invalid')
    else
      validate_absence_or_zero(:estimated_trial_length, 'present')
    end
  end

  def validate_trial_concluded_at
    if @record.interim_fee.try(:is_retrial_new_solicitor?)
      validate_presence(:trial_concluded_at, 'blank')
    else
      validate_absence(:trial_concluded_at, 'present')
    end
  end

  def validate_retrial_started_at
    if @record.interim_fee.try(:is_retrial_start?)
      validate_presence(:retrial_started_at, 'blank')
    else
      validate_absence(:retrial_started_at, 'present')
    end
  end

  def validate_retrial_estimated_length
    if @record.interim_fee.try(:is_retrial_start?)
      validate_presence(:retrial_estimated_length, 'blank')
      validate_numericality(:retrial_estimated_length, 0, nil, 'invalid')
    else
      validate_absence_or_zero(:retrial_estimated_length, 'present')
    end
  end

  def validate_effective_pcmh_date
    if @record.interim_fee.try(:is_effective_pcmh?)
      validate_presence(:effective_pcmh_date, 'blank')
    else
      validate_absence(:effective_pcmh_date, 'present')
    end
  end

  def validate_legal_aid_transfer_date
    if @record.interim_fee.try(:is_retrial_new_solicitor?)
      validate_presence(:legal_aid_transfer_date, 'blank')
    else
      validate_absence(:legal_aid_transfer_date, 'present')
    end
  end
end
