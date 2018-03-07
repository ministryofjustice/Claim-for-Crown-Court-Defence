class Claim::InterimClaimValidator < Claim::BaseClaimValidator
  include Claim::LitigatorCommonValidations

  def self.fields_for_steps
    {
      case_details: %i[
        case_type
        court
        case_number
        case_transferred_from_another_court
        transfer_court
        transfer_case_number
        advocate_category
        case_concluded_at
      ],
      defendants: [],
      offence_details: %i[offence],
      fees: %i[
        first_day_of_trial
        estimated_trial_length
        trial_concluded_at
        retrial_started_at
        retrial_estimated_length
        effective_pcmh_date
        legal_aid_transfer_date
        total
      ]
    }
  end

  private

  def interim_fee_absent?
    @record.interim_fee.nil?
  end

  def validate_case_concluded_at
    validate_absence(:case_concluded_at, 'present')
  end

  def validate_first_day_of_trial
    return if interim_fee_absent?

    if @record.interim_fee.is_trial_start?
      validate_presence(:first_day_of_trial, 'blank')
    else
      validate_absence(:first_day_of_trial, 'present') if @record.errors[:first_day_of_trial].empty?
    end
  end

  def validate_estimated_trial_length
    return if interim_fee_absent?

    if @record.interim_fee.is_trial_start?
      validate_presence_and_length(:estimated_trial_length)
    else
      validate_absence_or_zero(:estimated_trial_length, 'present')
    end
  end

  def validate_trial_concluded_at
    return if interim_fee_absent?

    if @record.interim_fee.is_retrial_new_solicitor?
      validate_presence_and_not_in_future(:trial_concluded_at)
    else
      validate_absence(:trial_concluded_at, 'present')
    end
  end

  def validate_retrial_started_at
    return if interim_fee_absent?

    if @record.interim_fee.is_retrial_start?
      validate_presence_and_not_in_future(:retrial_started_at)
    else
      validate_absence(:retrial_started_at, 'present')
    end
  end

  def validate_retrial_estimated_length
    return if interim_fee_absent?

    if @record.interim_fee.is_retrial_start?
      validate_presence_and_length(:retrial_estimated_length)
    else
      validate_absence_or_zero(:retrial_estimated_length, 'present')
    end
  end

  def validate_effective_pcmh_date
    return if interim_fee_absent?

    if @record.interim_fee.is_effective_pcmh?
      validate_presence_and_not_in_future(:effective_pcmh_date)
    else
      validate_absence(:effective_pcmh_date, 'present')
    end
  end

  def validate_legal_aid_transfer_date
    return if interim_fee_absent?

    if @record.interim_fee.is_retrial_new_solicitor?
      validate_presence_and_not_in_future(:legal_aid_transfer_date)
    else
      validate_absence(:legal_aid_transfer_date, 'present')
    end
  end

  # helpers for common validation combos
  #
  def validate_presence_and_not_in_future(attribute)
    validate_presence(attribute, 'blank')
    validate_on_or_before(Date.today, attribute, 'check_not_in_future')
  end

  def validate_presence_and_length(attribute)
    validate_presence(attribute, 'blank')
    # an interim fee cannot be claimed unless the trial will last 10 days or more
    validate_numericality(attribute, 'interim_invalid', 10, nil)
  end
end
