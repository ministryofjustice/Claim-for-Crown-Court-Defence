class Claim::InterimClaimPresenter < Claim::BaseClaimPresenter

  def requires_trial_dates?
    false
  end

  def requires_retrial_dates?
    false
  end

  def can_have_expenses?
    false
  end

end
