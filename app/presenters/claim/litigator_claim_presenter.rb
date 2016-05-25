class Claim::LitigatorClaimPresenter < Claim::BaseClaimPresenter
  # TODO: Any differences in baseclaimpresenters for litigators and advocates to be handled here

  def disbursements_total
    h.number_to_currency(claim.disbursements_total)
  end

  def pretty_type
    'LGFS Final'
  end
end
