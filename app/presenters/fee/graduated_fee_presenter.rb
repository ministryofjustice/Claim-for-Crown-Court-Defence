class Fee::GraduatedFeePresenter < Fee::BaseFeePresenter
  def rate
    not_applicable
  end

  def days_claimed
    claim.actual_trial_length
  end
end
