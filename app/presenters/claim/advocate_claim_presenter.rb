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

end
