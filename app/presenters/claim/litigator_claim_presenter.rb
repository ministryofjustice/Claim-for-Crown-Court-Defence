class Claim::LitigatorClaimPresenter < Claim::BaseClaimPresenter
  # TODO: Any differences in baseclaimpresenters for litigators and advocates to be handled here

  def disbursements_total
    h.number_to_currency(claim.disbursements_total)
  end

  def pretty_type
    'LGFS Final'
  end

  def raw_disbursements_total
    claim.disbursements_total || 0
  end

  def raw_fixed_fee_total
    claim.fixed_fee&.amount || 0
  end

  def raw_grad_fee_total
    claim.graduated_fee&.amount || 0
  end

  def raw_warrant_fee_total
    claim.warrant_fee&.amount || 0
  end

  def raw_misc_fee_total
    claim.calculate_fees_total(:misc) || 0
  end

  def raw_fixed_fee_combined_total
    raw_fixed_fee_total + raw_warrant_fee_total + raw_grad_fee_total + raw_misc_fee_total
  end

end
