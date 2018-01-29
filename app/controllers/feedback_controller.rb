require 'google_analytics/api'

class FeedbackController < ApplicationController
  skip_load_and_authorize_resource only: %i[new create]
  before_action :suppress_hotline_link

  def new
    @feedback = Feedback.new(type: type, referrer: referrer_path)
    render "feedback/#{@feedback.type}"
  end

  def create
    @feedback = Feedback.new(merged_feedback_params)
    if @feedback.save
      submit_feedback_google_event if @feedback.is?('feedback')
      redirect_to after_create_url, notice: 'Feedback submitted'
    else
      render "feedback/#{@feedback.type}"
    end
  end

  private

  def submit_feedback_google_event
    rating = merged_feedback_params[:rating]
    label = Feedback::RATINGS[rating.to_i].downcase.tr(' ', '_')
    GoogleAnalytics::Api.event('satisfaction', rating, label, params[:ga_client_id])
  end

  def type
    %w[feedback bug_report].include?(params[:type]) ? params[:type] : 'feedback'
  end

  def referrer_path
    URI(request.referrer.to_s).path
  end

  def merged_feedback_params
    feedback_params.merge(email: user_email_or_anonymous,
                          user_agent: request.user_agent)
  end

  def user_email_or_anonymous
    if current_user
      current_user.email
    else
      email_from_user_id || params[:feedback][:email] || 'anonymous'
    end
  end

  def email_from_user_id
    User.active.find(params[:user_id])&.email
  rescue ActiveRecord::RecordNotFound
    nil
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
      :type,
      :comment,
      :rating,
      :event,
      :outcome,
      :case_number,
      :referrer,
      :email
    )
  end
end
