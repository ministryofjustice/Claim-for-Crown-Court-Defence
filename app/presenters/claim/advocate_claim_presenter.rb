class Claim::AdvocateClaimPresenter < Claim::BaseClaimPresenter
  def pretty_type
    'AGFS Final'
  end

  def can_have_disbursements?
    false
  end
end
