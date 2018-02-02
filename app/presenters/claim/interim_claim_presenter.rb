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

  def disbursement_only?
    claim.interim_fee&.is_disbursement?
  end

  def pretty_type
    'LGFS Interim'
  end
end
