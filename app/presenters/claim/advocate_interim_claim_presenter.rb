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
end
