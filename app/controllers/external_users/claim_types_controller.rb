class ExternalUsers::ClaimTypesController < ExternalUsers::ApplicationController

  skip_load_and_authorize_resource

  before_action :init_claim_types
  before_action :set_claim_types_for_provider, only: [:selection]

  def selection
    redirect_to external_users_claims_url, error: 'AGFS/LGFS claim type choice incomplete' and return if @claim_types.empty?
    render and return if @claim_types.size > 1
    redirect_for_claim_type
  end

  def chosen
    @claim_types << case params['scheme_chosen'].downcase
                    when 'agfs'
                      Claim::AdvocateClaim
                    when 'lgfs_final'
                      Claim::LitigatorClaim
                    when 'lgfs_interim'
                      Claim::InterimClaim
                    when 'lgfs_transfer'
                      Claim::TransferClaim
                    end
    redirect_for_claim_type
  end

  private

  def redirect_for_claim_type
    if @claim_types.first == Claim::AdvocateClaim
      redirect_to new_advocates_claim_url
    elsif @claim_types.first == Claim::LitigatorClaim
      redirect_to new_litigators_claim_url
    elsif @claim_types.first == Claim::InterimClaim
      redirect_to new_litigators_interim_claim_url
    elsif @claim_types.first == Claim::TransferClaim
      redirect_to new_litigators_transfer_claim_url
    else
      redirect_to external_users_claims_url, error: 'Invalid claim types made available to current user'
    end
  end

  def set_claim_types_for_provider
    context = Claims::ContextMapper.new(current_user.persona)
    @claim_types = context.available_claim_types
  end

  def init_claim_types
    @claim_types = []
  end
end
