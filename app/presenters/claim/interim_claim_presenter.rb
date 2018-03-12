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

  def type_identifier
    'lgfs_interim'
  end

  def raw_fixed_fees_total
    claim.fixed_fee&.amount || 0
  end

  def raw_interim_fees_total
    claim.interim_fee&.amount || 0
  end

   def raw_misc_fees_total
    claim.calculate_fees_total(:misc) || 0
  end

  def raw_warrant_fees_total
    claim.warrant_fee&.amount || 0
  end

  def raw_disbursements_total
    claim.disbursements_total || 0
  end

  def raw_disbursements_vat
    claim.disbursements_vat || 0
  end

  def raw_expenses_total
    claim.expenses_total
  end

  def raw_expenses_vat
    claim.expenses_vat
  end

  def raw_vat_amount
    claim.vat_amount
  end

  def raw_total_excl
    claim.total
  end

  def raw_total_inc
    claim.total + claim.vat_amount
  end
end
