class Claim::AdvocateClaimPresenter < Claim::BaseClaimPresenter
  def pretty_type
    'AGFS Final'
  end

  def can_have_disbursements?
    false
  end

  def current_step
    submission_stages[super - 1]
  end
end
