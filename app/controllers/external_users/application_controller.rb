class ExternalUsers::ApplicationController < ApplicationController
  before_action :authenticate_external_user!

  private

  def authenticate_external_user!
    return if user_signed_in? && current_user.persona.is_a?(ExternalUser)
    respond_to do |format|
      format.html do
        redirect_to root_path_url_for_user, alert: t('requires_external_user_authorisation')
      end
      format.json do
        render status: :unauthorized, json: { error: t('requires_external_user_authorisation') }
      end
    end
  end

  def date_attributes_for(date_param)
    date_params = []
    %w[dd mm yyyy].each do |part|
      date_params.push("#{date_param}_#{part}".to_sym)
    end
    date_params
  end

  def common_dates_attended_attributes
    {
      dates_attended_attributes: [
        :id,
        :fee_id,
        date_attributes_for(:date),
        date_attributes_for(:date_to),
        :_destroy
      ]
    }
  end

  def common_fees_attributes
    [
      :id,
      :claim_id,
      :fee_type_id,
      :sub_type_id,
      :fee_id,
      :quantity,
      :rate,
      :amount,
      :case_numbers,
      :_destroy,
      date_attributes_for(:date),
      common_dates_attended_attributes
    ]
  end

  def claim_updater
    Claims::ExternalUserClaimUpdater.new(@claim, current_user: current_user)
  end
end
