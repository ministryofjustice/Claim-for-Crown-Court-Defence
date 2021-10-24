module Stats
  class StatsReportGenerator
    class InvalidReportType < StandardError; end

    # rubocop:disable Metrics/MethodLength
    def self.for(report_type)
      Hash.new({ class: ReportGenerator, args: [report_type] }).merge(
        management_information:
          { class: ManagementInformationGenerator, args: [] },
        agfs_management_information:
          { class: ManagementInformationGenerator, args: [{ scheme: :agfs }] },
        lgfs_management_information:
          { class: ManagementInformationGenerator, args: [{ scheme: :lgfs }] },
        management_information_v2:
          { class: Stats::ManagementInformation::DailyReportGenerator, args: [] },
        agfs_management_information_v2:
          { class: Stats::ManagementInformation::DailyReportGenerator, args: [{ scheme: :agfs }] },
        lgfs_management_information_v2:
          { class: Stats::ManagementInformation::DailyReportGenerator, args: [{ scheme: :lgfs }] },
        agfs_management_information_daily_statistics:
          { class: Stats::ManagementInformation::DailyCountGenerator, args: [{ scheme: :agfs }] },
        lgfs_management_information_daily_statistics:
          { class: Stats::ManagementInformation::DailyCountGenerator, args: [{ scheme: :lgfs }] }
      )[report_type.to_sym]
    end
    # rubocop:enable Metrics/MethodLength

    def self.call(report_type)
      new(report_type).call
    end

    def initialize(report_type)
      @report_type = report_type
    end

    def call
      validate_report_type
      StatsReport.clean_up(report_type)
      return if StatsReport.generation_in_progress?(report_type)
      report_record = Stats::StatsReport.record_start(report_type)
      report_contents = generate_new_report
      report_record.write_report(report_contents)
    rescue StandardError => e
      report_record&.update(status: 'error')
      notify_error(report_record, e)
      raise
    end

    private

    attr_reader :report_type

    def validate_report_type
      raise InvalidReportType unless StatsReport::TYPES.include?(report_type.to_s)
    end

    def generate_new_report
      generator = self.class.for(report_type)
      generator[:class].call(*generator[:args])
    end

    def notify_error(report_record, error)
      return unless Settings.notify_report_errors
      ActiveSupport::Notifications.instrument('call_failed.stats_report',
                                              id: report_record&.id, name: report_type, error: error)
    end
  end
end
