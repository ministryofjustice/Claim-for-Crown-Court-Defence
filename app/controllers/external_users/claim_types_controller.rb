class ExternalUsers::ClaimTypesController < ExternalUsers::ApplicationController
  skip_load_and_authorize_resource

  before_action :set_available_fee_schemes_for_provider, only: %i[selection]
  before_action :disable_primary_navigation, only: %i[selection]

  def selection
    if @available_fee_schemes.empty?
      redirect_to(
        external_users_claims_url,
        alert: error_message(:claim_type_choice_incomplete)
      ) && return
    end

    track_visit(url: 'external_user/claim_types', title: 'Choose claim type')
    @available_fee_schemes.size > 1 ? render : redirect_for_fee_scheme(@available_fee_schemes.first)
  end

  def chosen
    redirect_for_fee_scheme(params['scheme_chosen'])
  end

  private

  def redirect_for_fee_scheme(fee_scheme)
    redirect_url = claim_type_redirect_url_for(fee_scheme)
    if redirect_url
      redirect_to redirect_url
    else
      redirect_to external_users_claims_url, alert: error_message(:invalid_claim_types)
    end
  end

  def set_available_fee_schemes_for_provider
    context = Claims::ContextMapper.new(current_user.persona)
    @available_fee_schemes = context.available_compreensive_schemes
  end

  def claim_type_redirect_url_for(fee_scheme)
    {
      'agfs'          => new_advocates_claim_url,
      'lgfs_final'    => new_litigators_claim_url,
      'lgfs_interim'  => new_litigators_interim_claim_url,
      'lgfs_transfer' => new_litigators_transfer_claim_url
    }[fee_scheme.to_s]
  end

  def error_message(error_code)
    t(".errors.#{error_code}")
  end
end
