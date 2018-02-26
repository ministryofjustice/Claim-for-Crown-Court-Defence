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

  def raw_fixed_fee_total
    claim.fixed_fee&.amount || 0
  end

  def raw_fixed_fee_combined_total
    raw_fixed_fee_total + raw_warrant_fee_total + raw_grad_fee_total + raw_misc_fee_total
  end
end
