class BugReportController < ApplicationController
  skip_load_and_authorize_resource only: [:new, :create]

  def new
    @bug_report = BugReport.new
  end

  def create
    @bug_report = BugReport.new(merged_bug_report_params)
    if @bug_report.save
      redirect_to after_create_url, notice: 'Feedback submitted'
    else
      render :new
    end
  end

  private

  def merged_bug_report_params
    bug_report_params.merge({
      email: (current_user.email rescue 'anonymous'),
      referrer: request.referer,
      user_agent: request.user_agent
    })
  end

  def after_create_url
    if current_user
      root_path_url_for_user
    else
      new_user_session_url
    end
  end

  def bug_report_params
    params.require(:bug_report).permit(
      :event,
      :outcome
    )
  end
end
