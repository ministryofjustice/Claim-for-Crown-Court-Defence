class FeedbackController < ApplicationController
  skip_load_and_authorize_resource only: [:new, :create]

  def new
    @feedback = Feedback.new(type: type)
    render "feedback/#{type}"
  end

  def create
    @feedback = Feedback.new(merged_feedback_params)
    if @feedback.save
      redirect_to after_create_url, notice: 'Feedback submitted'
    else
      render "feedback/#{type}"
    end
  end

  private

  def type
    %w( feedback bug_report ).include?(params[:type]) ? params[:type] : 'feedback'
  end

  def merged_feedback_params
    feedback_params.merge({
      type: type,
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
      :rating,
      :event,
      :outcome
    )
  end
end
