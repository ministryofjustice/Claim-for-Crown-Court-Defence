class CaseWorkers::ApplicationController < ApplicationController
  before_action :authenticate_case_worker!

  private

  def authenticate_case_worker!
    unless user_signed_in? && current_user.case_worker?
      redirect_to root_url, alert: 'Must be signed in as a case worker'
    end
  end
end
