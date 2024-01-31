class Fee::InterimFeePresenter < Fee::BaseFeePresenter
  presents :fee

  delegate :estimated_trial_length, :retrial_estimated_length, to: :_claim

  def quantity
    if fee.is_interim_warrant?
      nil
    else
      super
    end
  end

  def rate
    not_applicable
  end

  def effective_pcmh_date
    format_date(_claim.effective_pcmh_date)
  end

  def legal_aid_transfer_date
    format_date(_claim.legal_aid_transfer_date)
  end

  def warrant_issued_date
    format_date(fee.warrant_issued_date)
  end

  def warrant_executed_date
    format_date(fee.warrant_executed_date)
  end

  private

  def _claim
    fee.claim
  end
end
