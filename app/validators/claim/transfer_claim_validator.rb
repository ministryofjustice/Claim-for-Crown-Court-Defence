class Claim::TransferClaimValidator < Claim::BaseClaimValidator
  include Claim::LitigatorCommonValidations

  def self.fields_for_steps
    [
      [
        :case_type,
        :court,
        :case_number,
        :advocate_category,
        :offence,
        :case_concluded_at
      ],
      [
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

  def validate_first_day_of_trial
    validate_presence(:first_day_of_trial, 'blank') if requires_trial_dates?
  end

  def validate_trial_concluded_at
    validate_presence(:trial_concluded_at, 'blank') if requires_trial_dates?
  end

  def validate_retrial_started_at
    validate_presence(:retrial_started_at, 'blank') if requires_trial_dates?
  end

  def validate_effective_pcmh_date
    validate_presence(:effective_pcmh_date, 'blank') if @record.interim_fee.try(:is_effective_pcmh?)
  end

  def validate_legal_aid_transfer_date
    validate_presence(:effective_pcmh_date, 'blank') if @record.interim_fee.try(:is_retrial_new_solicitor?)
  end
end
