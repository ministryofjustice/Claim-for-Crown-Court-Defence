class CaseWorkers::ApplicationController < ApplicationController
  before_action :authenticate_case_worker!

  def set_claim_carousel_info
    session[:claim_ids] = @claims.all.map(&:id)
    session[:claim_count] = @claims.try(:size)
  end

  private

  def authenticate_case_worker!
    unless user_signed_in? && current_user.persona.is_a?(CaseWorker)
      redirect_to root_path_url_for_user, alert: 'Must be signed in as a case worker'
    end
  end
end
