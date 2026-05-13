require 'csv'

module CaseWorkers
  module Admin
    class ManagementInformationController < CaseWorkers::Admin::ApplicationController
      include ActiveStorage::SetCurrent

      skip_load_and_authorize_resource only: %i[index create]
      before_action -> { authorize! :view, :management_information }, only: %i[index create]
      before_action :validate_report_type, only: :create
      before_action :validate_report_type_is_updatable, only: :create, if: -> { report_params[:update].present? }
      before_action :validate_date, only: :create, if: -> { report_params[:update].present? && Stats::StatsReport.reports[report_params[:report_type]].date_required? }
      before_action :set_date, only: :create, if: -> { report_params[:update].present? && Stats::StatsReport.reports[report_params[:report_type]].date_required? }

      def index
        @available_reports = Stats::StatsReport::REPORTS.index_with do |report|
          Stats::StatsReport.most_recent_by_type(report.name)
        end
      end

      def create
        return update_report if report_params[:update].present?

        download_report
      end

      private

      def update_report
        StatsReportGenerationJob.perform_later(report_type: report_params[:report_type], start_at: @start_at)
        message = t('case_workers.admin.management_information.job_scheduled')
        redirect_to case_workers_admin_management_information_index_url, flash: { notification: message }
      end

      def download_report
        log_download_start
        record = Stats::StatsReport.most_recent_by_type(report_params[:report_type])

        if record.document.attached?
          redirect_to record.document.blob.url(disposition: 'attachment'), allow_other_host: true
        else
          redirect_to case_workers_admin_management_information_index_url, alert: t('.missing_report')
        end
      end

      def validate_report_type
        return if Stats::StatsReport.reports[report_params[:report_type]]

        redirect_to case_workers_admin_management_information_index_url, alert: t('.invalid_report_type')
      end

      def validate_report_type_is_updatable
        return if Stats::StatsReport.reports[report_params[:report_type]].updatable?

        redirect_to case_workers_admin_management_information_index_url, alert: t('.report_cannot_be_updated')
      end

      def report_params
        params.expect(report: %i[report_type start_at update])
      end

      def validate_date
        return if report_params['start_at(1i)'].present?

        redirect_to(case_workers_admin_management_information_index_url, alert: t('.invalid_report_date'))
      end

      def set_date
        @start_at ||= Date.new(report_params['start_at(1i)'].to_i,
                               report_params['start_at(2i)'].to_i,
                               report_params['start_at(3i)'].to_i)
      rescue Date::Error
        redirect_to case_workers_admin_management_information_index_url, alert: t('.invalid_report_date')
      end

      def log_download_start
        LogStuff.info(class: 'CaseWorkers::Admin::ManagementInformationController',
                      action: 'download',
                      downloading_user_id: @current_user&.id) do
          'MI Report download started'
        end
      end
    end
  end
end
