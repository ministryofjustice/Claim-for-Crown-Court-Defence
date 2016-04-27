class Fee::InterimFeePresenter < Fee::BaseFeePresenter
  presents :fee

  def effective_pcmh_date
    format_date(_claim.effective_pcmh_date)
  end

  def first_day_of_trial
    format_date(_claim.first_day_of_trial)
  end

  def retrial_started_at
    format_date(_claim.retrial_started_at)
  end

  def trial_concluded_at
    format_date(_claim.trial_concluded_at)
  end

  def legal_aid_transfer_date
    format_date(_claim.legal_aid_transfer_date)
  end

  def estimated_trial_length
    _claim.estimated_trial_length
  end

  def retrial_estimated_length
    _claim.retrial_estimated_length
  end

  private

  def format_date(date)
    date.strftime(Settings.date_format) rescue '[date error]'
  end

  def _claim
    fee.claim
  end
end
