class ExternalUsers::ClaimTypeController < ExternalUsers::ApplicationController

  skip_load_and_authorize_resource

  def options
    context = Claims::ContextMapper.new(current_user.persona)
    available_types = context.available_claim_types
    redirect_to claim_options_external_users_claims_path if available_types.size > 1
    redirect_to external_users_claims_path, error: 'AGFS/LGFS claim type choice incomplete' if available_types.empty?
    if available_types.first == Claim::AdvocateClaim
      redirect_to new_advocates_claim_path
    elsif available_types.first == Claim::LitigatorClaim
      redirect_to new_litigators_claim_path
    else
      redirect_to external_users_claims_path, error: 'Invalid claim type'
    end
  end

end