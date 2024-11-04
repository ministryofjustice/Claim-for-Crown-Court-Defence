class FeedbackController < ApplicationController
  skip_load_and_authorize_resource only: %i[new create]
  before_action :suppress_hotline_link
  before_action :setup_page

  def new
    @feedback = Feedback.new(type:, referrer: referrer_path)
    render "feedback/#{@feedback.type}"
  end

  def create
    @feedback = Feedback.new(merged_feedback_params)

    if @feedback.save
      redirect_to after_create_url, notice: @feedback.response_message
    else
      flash.now[:error] = @feedback.response_message if @feedback.response_message
      render "feedback/#{@feedback.type}"
    end
  end

  private

  def sender
    if params['feedback']['type'] == 'feedback' && !Settings.zendesk_feedback_enabled?
      SurveyMonkeySender::Feedback
    else
      ZendeskSender
    end
  end

  def type
    %w[feedback bug_report].include?(params[:type]) ? params[:type] : 'feedback'
  end

  def referrer_path
    URI(request.referer.to_s).path
  end

  def merged_feedback_params
    feedback_params.merge(email: user_email_or_anonymous,
                          user_agent: request.user_agent,
                          sender:)
  end

  def user_email_or_anonymous
    if current_user
      current_user.email
    else
      params[:feedback][:email] || 'anonymous'
    end
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
      :task, :rating, :comment, :other_reason, :type,
      :event,
      :outcome,
      :case_number,
      :referrer,
      :email,
      reason: []
    )
  end

  def setup_page
    @feedback_form = FeedbackForm.new if type == 'feedback'
  end
end
