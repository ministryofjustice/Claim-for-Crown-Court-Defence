class Fee::InterimFeeTypePresenter < BasePresenter
  presents :fee_type

  def data_attributes
    {
      effective_pcmh:       fee_type.is_effective_pcmh?,
      trial_dates:          fee_type.is_trial_start?,
      legal_aid_transfer:   fee_type.is_retrial_new_solicitor?,
      trial_concluded:      fee_type.is_retrial_new_solicitor?,
      retrial_dates:        fee_type.is_retrial_start?,
      ppe:                  is_not_disbursement_or_warrant?,
      fee_total:            is_not_disbursement?,
      warrant:              fee_type.is_interim_warrant?,
      disbursements:        is_not_warrant?
    }
  end

  private

  def is_not_disbursement_or_warrant?
    is_not_disbursement? && is_not_warrant?
  end

  def is_not_disbursement?
    !fee_type.is_disbursement?
  end

  def is_not_warrant?
    !fee_type.is_interim_warrant?
  end
end
