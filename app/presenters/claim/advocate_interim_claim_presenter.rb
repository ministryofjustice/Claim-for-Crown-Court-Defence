class Claim::AdvocateInterimClaimPresenter < Claim::BaseClaimPresenter
  def pretty_type
    'AGFS Interim'
  end

  def type_identifier
    'agfs_interim'
  end

  def can_have_disbursements?
    false
  end

  def raw_warrant_fees_total
    claim.warrant_fee&.amount || 0
  end
  present_with_currency :warrant_fees_total
end
