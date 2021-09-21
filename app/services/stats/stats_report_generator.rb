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
      raise InvalidReportType unless StatsReport::TYPES.include?(report_type.to_s)
    end

    def generate_new_report
      return management_information_generator if report_type.include?('management_information')

      ReportGenerator.call(report_type, **options)
    end

    def management_information_generator
      case report_type.to_sym
      when :agfs_management_information
        options[:claim_scope] = :agfs
      when :lgfs_management_information
        options[:claim_scope] = :lgfs
      end

      ManagementInformationGenerator.call(options)
    end

    def notify_error(report_record, error)
      return unless Settings.notify_report_errors
      ActiveSupport::Notifications.instrument('call_failed.stats_report',
                                              id: report_record&.id, name: report_type, error: error)
    end
  end
end
