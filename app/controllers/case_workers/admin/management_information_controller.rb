require 'csv'

module CaseWorkers
  module Admin
    class ManagementInformationController < CaseWorkers::Admin::ApplicationController
      include ActiveStorage::SetCurrent

      skip_load_and_authorize_resource only: %i[index generate create]
      before_action -> { authorize! :view, :management_information }, only: %i[index generate create]
      before_action :validate_report_type, only: %i[generate create]
      before_action :validate_report_type_is_updatable, only: %i[generate create]
      before_action :validate_and_set_date, only: %i[create]

      def index
        @available_reports = Stats::StatsReport::REPORTS.index_with do |report|
          Stats::StatsReport.most_recent_by_type(report.name)
        end
      end

      def generate
        StatsReportGenerationJob.perform_later(report_type: params[:report_type])
        message = t('case_workers.admin.management_information.job_scheduled')
        redirect_to case_workers_admin_management_information_url, flash: { notification: message }
      end

      def create
        StatsReportGenerationJob.perform_later(report_type: report_params[:report_type], start_at: @start_at)
        message = t('case_workers.admin.management_information.job_scheduled')
        redirect_to case_workers_admin_management_information_url, flash: { notification: message }
      end

      private

      def validate_report_type
        return if Stats::StatsReport.reports[params[:report_type]]

        redirect_to case_workers_admin_management_information_url, alert: t('.invalid_report_type')
      end

      def validate_report_type_is_updatable
        return if Stats::StatsReport.reports[params[:report_type]].updatable?

        redirect_to case_workers_admin_management_information_url, alert: t('.report_cannot_be_updated')
      end

      def report_params
        params.permit(
          :report_type,
          :start_at
        )
      end

      def validate_and_set_date
        @start_at ||= Date.new(report_params['start_at(1i)'].to_i,
                               report_params['start_at(2i)'].to_i,
                               report_params['start_at(3i)'].to_i)
      rescue Date::Error
        redirect_to case_workers_admin_management_information_url, alert: t('.invalid_report_date')
      end

      # def log_download_start
      #   LogStuff.info(class: 'CaseWorkers::Admin::ManagementInformationController',
      #                 action: 'download',
      #                 downloading_user_id: @current_user&.id) do
      #     'MI Report download started'
      #   end
      # end
    end
  end
end
