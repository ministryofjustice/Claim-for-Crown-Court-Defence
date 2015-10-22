class FeedbackController < ApplicationController
  def new
    @feedback = Feedback.new
  end

  def create
    redirect_to root_path_url_for_user, notice: 'Feedback submitted'
  end
end
