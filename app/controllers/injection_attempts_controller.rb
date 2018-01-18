class InjectionAttemptsController < ApplicationController
  def dismiss
    @injection_attempt = InjectionAttempt.find(injection_attempt_params[:id])
    @dismissed = @injection_attempt.soft_delete
    respond_to :js
  end

  private

  def injection_attempt_params
    params.permit(:id)
  end
end
