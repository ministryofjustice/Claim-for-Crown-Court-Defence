class Fee::InterimFeeTypePresenter < BasePresenter

  presents :fee_type

  def data_attributes
    {
      effective_pcmh:       fee_type.is_effective_pcmh?,
      trial_dates:          fee_type.is_trial_start?,
      legal_aid_transfer:   fee_type.is_retrial_new_solicitor?,
      retrial:              fee_type.is_retrial_start?,
      ppe:                  is_disbursement_or_warrant?,
      interim_fee_total:    is_disbursement_or_warrant?,
      warrant:              fee_type.is_warrant?,
      disbursement:         is_not_warrant?
    }
  end


  private

  def is_disbursement_or_warrant?
    fee_type.is_disbursement? || fee_type.is_warrant? ? false : true
  end

  def is_not_warrant?
    !fee_type.is_warrant?
  end

end