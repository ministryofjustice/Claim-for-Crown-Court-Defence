class ExternalUsers::ClaimTypeController < ExternalUsers::ApplicationController

  skip_load_and_authorize_resource

  before_action :set_claim_types_for_provider, only: [:options]

  def options
    redirect_to external_users_claim_options_path and return if @claim_types.size > 1
    redirect_to external_users_claims_path, error: 'AGFS/LGFS claim type choice incomplete' if @claim_types.empty?
    if @claim_types.first == Claim::AdvocateClaim
      redirect_to new_advocates_claim_path
    elsif @claim_types.first == Claim::LitigatorClaim
      redirect_to new_litigators_claim_path
    else
      redirect_to external_users_claims_path, error: 'Invalid claim type'
    end
  end

private

  def set_claim_types_for_provider
    context = Claims::ContextMapper.new(current_user.persona)
    @claim_types = context.available_claim_types
  end

end