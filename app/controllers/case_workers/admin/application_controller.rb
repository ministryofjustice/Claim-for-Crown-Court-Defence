class CaseWorkers::Admin::ApplicationController < ApplicationController
  layout 'case_worker'
  before_action :authenticate_case_worker_admin!

  private

  def authenticate_case_worker_admin!
    unless user_signed_in? && current_user.persona.is_a?(CaseWorker) && current_user.persona.admin?
      redirect_to root_path_url_for_user, alert: 'Must be signed in as a case worker admin'
    end
  end
end
