class ExternalUsers::ClaimTypesController < ExternalUsers::ApplicationController
  skip_load_and_authorize_resource

  before_action :set_available_claim_types_for_provider, only: %i[selection]
  layout 'claim_forms', only: %i[selection]

  def selection
    if @available_claim_types.empty?
      redirect_to(
        external_users_claims_url,
        alert: error_message(:claim_type_choice_incomplete)
      ) && return
    end

    track_visit(url: 'external_user/claim_types', title: 'Choose claim type')
    @available_claim_types.size > 1 ? render : redirect_for_claim_type(@available_claim_types.first)
  end

  def chosen
    redirect_for_claim_type(params[:claim_type])
  end

  private

  def redirect_for_claim_type(claim_type)
    redirect_url = claim_type_redirect_url_for(claim_type)
    if redirect_url
      redirect_to redirect_url
    else
      redirect_to external_users_claims_url, alert: error_message(:invalid_claim_types)
    end
  end

  def set_available_claim_types_for_provider
    context = Claims::ContextMapper.new(current_user.persona)
    @available_claim_types = context.available_comprehensive_claim_types
  end

  def claim_type_redirect_url_for(claim_type)
    {
      'agfs'          => new_advocates_claim_url,
      'agfs_interim'  => new_advocates_interim_claim_url,
      'lgfs_final'    => new_litigators_claim_url,
      'lgfs_interim'  => new_litigators_interim_claim_url,
      'lgfs_transfer' => new_litigators_transfer_claim_url
    }[claim_type.to_s]
  end

  def error_message(error_code)
    t(".errors.#{error_code}")
  end
end
