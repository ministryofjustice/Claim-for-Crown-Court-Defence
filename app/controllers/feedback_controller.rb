class FeedbackController < ApplicationController
  skip_load_and_authorize_resource only: [:new, :create]

  def new
    @feedback = Feedback.new
  end

  def create
    @feedback = Feedback.new(merged_feedback_params)
    if @feedback.save
      redirect_to after_create_url, notice: 'Feedback submitted'
    else
      render :new
    end
  end

  private

  def merged_feedback_params
    feedback_params.merge({
      email: (current_user.email rescue (email_from_user_id || 'anonymous')),
      referrer: request.referer,
      user_agent: request.user_agent
    })
  end

  def email_from_user_id
    User.find(params[:user_id]).try(:email) rescue nil
  end

  def after_create_url
    if current_user
      root_path_url_for_user
    else
      new_user_session_url
    end
  end

  def feedback_params
    params.require(:feedback).permit(
      :comment,
      :rating
    )
  end
end
