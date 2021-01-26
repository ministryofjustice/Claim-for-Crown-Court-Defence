class ExternalUsers::ClaimTypesController < ExternalUsers::ApplicationController
  skip_load_and_authorize_resource

  before_action :set_available_claim_types_for_provider, only: %i[new create]
  layout 'claim_forms', only: %i[selection]

  def new
    if @available_claim_types.empty?
      redirect_to(
        external_users_claims_url,
        alert: t('external_users.claim_types.new.errors.claim_types_unavailable')
      ) && return
    end

    @claim_type = ClaimType.new

    track_visit(url: 'external_user/claim_types', title: 'Choose claim type')
    @available_claim_types.size > 1 ? render : redirect_for_claim_type(@available_claim_types.first)
  end

  def create
    @claim_type = ClaimType.new(claim_type_params[:claim_type])

    if @claim_type.valid?
      redirect_for_claim_type(@claim_type.id)
    else
      render :new
    end
  end

  private

  def claim_type_params
    params.permit(claim_type: :id)
  end

  # TODO should not be possible to reach this else statement
  def redirect_for_claim_type(claim_type)
    redirect_url = claim_type_redirect_url_for(claim_type)
    if redirect_url
      redirect_to claim_type_redirect_url_for(claim_type)
    else
      redirect_to external_users_claims_path, alert: t('external_users.claim_types.new.errors.claim_type_invalid')
    end
  end

  def set_available_claim_types_for_provider
    context = Claims::ContextMapper.new(current_user.persona)
    @available_claim_types = context.available_comprehensive_claim_types
  end

  def claim_type_redirect_url_for(claim_type)
    {
      'agfs' => new_advocates_claim_url,
      'agfs_interim' => new_advocates_interim_claim_url,
      'agfs_supplementary' => new_advocates_supplementary_claim_url,
      'agfs_hardship' => new_advocates_hardship_claim_url,
      'lgfs_final' => new_litigators_claim_url,
      'lgfs_interim' => new_litigators_interim_claim_url,
      'lgfs_transfer' => new_litigators_transfer_claim_url,
      'lgfs_hardship' => new_litigators_hardship_claim_url
    }[claim_type.to_s]
  end
end
