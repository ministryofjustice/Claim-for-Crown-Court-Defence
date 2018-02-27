class ExternalUsers::ClaimTypesController < ExternalUsers::ApplicationController
  skip_load_and_authorize_resource

  before_action :init_claim_types
  before_action :set_claim_types_for_provider, only: %i[selection]

  def selection
    if @claim_types.empty?
      redirect_to(
        external_users_claims_url,
        alert: error_message(:claim_type_choice_incomplete)
      ) && return
    end

    track_visit(url: 'external_user/claim_types', title: 'Choose claim type')
    @claim_types.size > 1 ? render : redirect_for_claim_type(@claim_types.first)
  end

  def chosen
    redirect_for_claim_type(claim_type_for_scheme(params['scheme_chosen']))
  end

  private

  SCHEME_TO_CLAIM_TYPE_MAPPING = {
    'agfs' => Claim::AdvocateClaim,
    'lgfs_final' => Claim::LitigatorClaim,
    'lgfs_interim' => Claim::InterimClaim,
    'lgfs_transfer' => Claim::TransferClaim
  }.freeze

  def redirect_for_claim_type(claim_type)
    redirect_url = claim_type_redirect_url(claim_type)
    if redirect_url
      redirect_to redirect_url
    else
      redirect_to external_users_claims_url, alert: error_message(:invalid_claim_types)
    end
  end

  def set_claim_types_for_provider
    context = Claims::ContextMapper.new(current_user.persona)
    @claim_types = context.available_claim_types
  end

  def init_claim_types
    @claim_types = []
  end

  def claim_type_redirect_url(claim_type)
    {
      'Claim::AdvocateClaim'  => new_advocates_claim_url,
      'Claim::LitigatorClaim' => new_litigators_claim_url,
      'Claim::InterimClaim'   => new_litigators_interim_claim_url,
      'Claim::TransferClaim'  => new_litigators_transfer_claim_url
    }[claim_type.to_s]
  end

  def claim_type_for_scheme(scheme)
    SCHEME_TO_CLAIM_TYPE_MAPPING[scheme&.downcase]
  end

  def error_message(error_code)
    t(".errors.#{error_code}")
  end
end
