class Claim::AdvocateClaimPresenter < Claim::BaseClaimPresenter
  def pretty_type
    'AGFS Final'
  end

  def can_have_disbursements?
    false
  end

  def current_step
    steps[super - 1]
  end

  private

  def steps
    %i[case_details defendants fees]
  end
end
