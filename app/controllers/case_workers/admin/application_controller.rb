class CaseWorkers::Admin::ApplicationController < ApplicationController
  before_action :authenticate_case_worker_admin!

  private

  def authenticate_case_worker_admin!
    unless user_signed_in? && current_user.rolable.is_a?(CaseWorker) && current_user.rolable.admin?
      redirect_to root_url, alert: 'Must be signed in as a case worker admin'
    end
  end
end
