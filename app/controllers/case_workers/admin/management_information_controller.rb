require 'csv'

class CaseWorkers::Admin::ManagementInformationController < CaseWorkers::Admin::ApplicationController
  skip_load_and_authorize_resource only: %i[index download generate]
  before_action -> { authorize! :view, :management_information }, only: %i[index download generate]

  def index
    mi_report = Stats::StatsReport.most_recent_management_information
    @time_generated = mi_report.started_at unless mi_report.nil?
  end

  def download
    mi_report = Stats::StatsReport.most_recent_management_information
    send_data mi_report.report, filename: mi_report.download_filename
  end

  def generate
    ManagemenInformationGenerationJob.perform_later
    redirect_to case_workers_admin_management_information_url,
                alert: t('case_workers.admin.management_information.alert')
  end
end
