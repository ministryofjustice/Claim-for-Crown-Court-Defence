module Stats
  class StatsReportGenerator
    class InvalidReportType < StandardError; end

    def self.call(report_type, options = {})
      new(report_type, options).call
    end

    def initialize(report_type, options = {})
      @report_type = report_type
      @options = options
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

    attr_reader :report_type, :options

    def validate_report_type
      return if StatsReport::TYPES.include?(report_type.to_s)
      raise InvalidReportType
    end

    def generate_new_report
      return ManagementInformationGenerator.call(options) if report_type.to_sym == :management_information

      ReportGenerator.call(report_type, **options)
    end

    def notify_error(report_record, error)
      return unless Settings.notify_report_errors
      ActiveSupport::Notifications.instrument 'call_failed.stats_report',
                                              id: report_record&.id, name: report_type, error: error
    end
  end
end
