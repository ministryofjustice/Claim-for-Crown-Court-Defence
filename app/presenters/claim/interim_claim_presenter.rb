class Claim::InterimClaimPresenter < Claim::BaseClaimPresenter
  present_with_currency :interim_fees_total, :warrant_fees_total

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

  def type_identifier
    'lgfs_interim'
  end

  def raw_fixed_fees_total
    claim.fixed_fee&.amount || 0
  end

  def raw_interim_fees_total
    claim.interim_fee&.amount || 0
  end

  def raw_warrant_fees_total
    claim.warrant_fee&.amount || 0
  end
end
