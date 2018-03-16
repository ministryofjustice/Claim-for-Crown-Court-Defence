class Claim::LitigatorClaimPresenter < Claim::BaseClaimPresenter
  # TODO: Any differences in baseclaimpresenters for litigators and advocates to be handled here
  present_with_currency :fixed_fees_total, :warrant_fees_total, :grad_fees_total

  def pretty_type
    'LGFS Final'
  end

  def type_identifier
    'lgfs_final'
  end

  def raw_fixed_fees_total
    claim.fixed_fee&.amount || 0
  end

  def raw_grad_fees_total
    claim.graduated_fee&.amount || 0
  end

  def raw_warrant_fees_total
    claim.warrant_fee&.amount || 0
  end
end
