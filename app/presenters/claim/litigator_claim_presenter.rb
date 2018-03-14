class Claim::LitigatorClaimPresenter < Claim::BaseClaimPresenter
  # TODO: Any differences in baseclaimpresenters for litigators and advocates to be handled here
  present_with_currency :fixed_fees_total, :misc_fees_total, :warrant_fees_total,
                        :grad_fees_total, :total_inc, :disbursements_total

  def disbursements_total
    h.number_to_currency(claim.disbursements_total)
  end

  def pretty_type
    'LGFS Final'
  end

  def type_identifier
    'lgfs_final'
  end

  def raw_fixed_fees_total
    claim.fixed_fee&.amount || 0
  end

  def raw_misc_fees_total
    claim.calculate_fees_total(:misc) || 0
  end

  def raw_grad_fees_total
    claim.graduated_fee&.amount || 0
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
