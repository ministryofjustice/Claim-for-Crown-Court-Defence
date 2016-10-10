class CaseWorkers::ApplicationController < ApplicationController
  before_action :authenticate_case_worker!

  # NOTE: limit needed to prevent cookie overflow
  def set_claim_carousel_info(limit=50)
    session[:claim_ids] = @claims.first(limit).map(&:id)
    session[:claim_count] = @claims.try(:size)
  end

  private

  def authenticate_case_worker!
    unless user_signed_in? && current_user.persona.is_a?(CaseWorker)
      redirect_to root_path_url_for_user, alert: t('requires_case_worker_authorisation')
    end
  end
end
