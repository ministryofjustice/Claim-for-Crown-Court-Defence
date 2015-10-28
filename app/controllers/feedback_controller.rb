class FeedbackController < ApplicationController
  skip_load_and_authorize_resource only: [:new, :create]

  def new
    @feedback = Feedback.new
  end

  def create
    redirect_to redirect_after_create_url, notice: 'Feedback submitted'
  end

  private

  def redirect_after_create_url
    if current_user
      root_path_url_for_user
    else
      new_user_session_url
    end
  end
end
