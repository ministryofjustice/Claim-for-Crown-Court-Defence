require 'csv'

class CaseWorkers::Admin::ManagementInformationController < CaseWorkers::Admin::ApplicationController
  include ActiveStorage::SetCurrent

  skip_load_and_authorize_resource only: %i[index download generate create]
  before_action -> { authorize! :view, :management_information }, only: %i[index download generate create]
  before_action :validate_report_type, only: %i[download generate create]
  before_action :validate_and_set_date, only: %i[create]

  def index
    @available_reports = Stats::StatsReport::REPORTS.index_with do |report|
      Stats::StatsReport.most_recent_by_type(report.name)
    end
  end

  def download
    log_download_start
    record = Stats::StatsReport.most_recent_by_type(params[:report_type])

    if record.document.attached?
      redirect_to record.document.blob.url(disposition: 'attachment')
    else
      redirect_to case_workers_admin_management_information_url, alert: t('.missing_report')
    end
  end

  def generate
    StatsReportGenerationJob.perform_later(params[:report_type])
    message = t('case_workers.admin.management_information.job_scheduled')
    redirect_to case_workers_admin_management_information_url, flash: { notification: message }
  end

  def create
    StatsReportGenerationJob.perform_later(report_params[:report_type], day: @day)
    message = t('case_workers.admin.management_information.job_scheduled')
    redirect_to case_workers_admin_management_information_url, alert: message
  end

  private

  def validate_report_type
    return if Stats::StatsReport.names.include?(params[:report_type])
    redirect_to case_workers_admin_management_information_url, alert: t('.invalid_report_type')
  end

  def report_params
    params.permit(
      :report_type,
      :day
    )
  end

  def validate_and_set_date
    @day ||= Date.iso8601("#{report_params['day(1i)']}-#{report_params['day(2i)']}-#{report_params['day(3i)']}")
  rescue Date::Error
    redirect_to case_workers_admin_management_information_url, alert: t('.invalid_report_date')
  end

  def log_download_start
    LogStuff.send(:info,
                  class: 'CaseWorkers::Admin::ManagementInformationController',
                  action: 'download',
                  downloading_user_id: @current_user&.id) do
      'MI Report download started'
    end
  end
end
