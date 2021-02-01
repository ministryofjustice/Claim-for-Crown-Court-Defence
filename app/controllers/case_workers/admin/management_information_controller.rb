require 'csv'

class CaseWorkers::Admin::ManagementInformationController < CaseWorkers::Admin::ApplicationController
  skip_load_and_authorize_resource only: %i[index download generate]
  before_action -> { authorize! :view, :management_information }, only: %i[index download generate]
  before_action :validate_report_type, only: %i[download generate]

  def index
    @available_report_types = Stats::StatsReport::TYPES.index_with do |report_type|
      Stats::StatsReport.most_recent_by_type(report_type)
    end
  end

  def download
    log_download_start
    record = Stats::StatsReport.most_recent_by_type(params[:report_type])
    if record.document?
      data = open(record.document_url).read
      content_type = record.document_content_type
    else
      data = record.report
      content_type = 'text/csv'
    end
    send_data data, filename: record.download_filename, type: content_type
  end

  def generate
    StatsReportGenerationJob.perform_later(params[:report_type])
    message = t('case_workers.admin.management_information.job_scheduled')
    redirect_to case_workers_admin_management_information_url, alert: message
  end

  private

  def validate_report_type
    return if Stats::StatsReport::TYPES.include?(params[:report_type])
    redirect_to case_workers_admin_management_information_url, alert: t('.invalid_report_type')
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
