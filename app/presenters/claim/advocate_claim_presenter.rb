class Claim::AdvocateClaimPresenter < Claim::BaseClaimPresenter
  def pretty_type
    'AGFS Final'
  end

  def can_have_disbursements?
    false
  end

  # 0.00 / £0.00
  def raw_fixed_fees_total
    claim.calculate_fees_total(:fixed)
  end

  def raw_basic_fees_total
    claim.calculate_fees_total(:basic)
  end

  def raw_fixed_fees_combined_total
    raw_fixed_fees_total + raw_basic_fees_total + raw_misc_fees_total
  end

  def raw_disbursements_total
    claim.disbursements_total || 0
  end

  def raw_disbursements_vat
    claim.disbursements_vat || 0
  end

  def raw_misc_fees_total
    claim.calculate_fees_total(:misc)
  end

  def raw_expenses_total
    claim.expenses_total
  end

  def raw_expenses_vat
    claim.expenses_vat
  end

  def raw_total_excl
    claim.total
  end

  def raw_total_inc
    claim.total + claim.vat_amount
  end

  def raw_vat_amount
    claim.vat_amount
  end

  def type_identifier
    "agfs_final"
  end

end
