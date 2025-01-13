module Stats
  class StatsReportGenerator
    class InvalidReportType < StandardError; end

    GENERATORS = {
      management_information: { class: ManagementInformationGenerator, default_args: {} },
      agfs_management_information: { class: ManagementInformationGenerator, default_args: { scheme: :agfs } },
      lgfs_management_information: { class: ManagementInformationGenerator, default_args: { scheme: :lgfs } },
      fee_scheme_usage: { class: FeeSchemeUsageGenerator, default_args: {} },
      management_information_v2: { class: Stats::ManagementInformation::DailyReportGenerator, default_args: {} },
      agfs_management_information_v2: {
        class: Stats::ManagementInformation::DailyReportGenerator,
        default_args: { scheme: :agfs }
      },
      lgfs_management_information_v2: {
        class: Stats::ManagementInformation::DailyReportGenerator,
        default_args: { scheme: :lgfs }
      },
      agfs_management_information_statistics: {
        class: Stats::ManagementInformation::DailyReportCountGenerator,
        default_args: { query_set: Stats::ManagementInformation::AGFSQuerySet.new, duration: (1.month - 1.day) }
      },
      lgfs_management_information_statistics: {
        class: Stats::ManagementInformation::DailyReportCountGenerator,
        default_args: { query_set: Stats::ManagementInformation::LGFSQuerySet.new, duration: (1.month - 1.day) }
      }
    }.freeze

    def self.for(report_type)
      GENERATORS[report_type.to_sym] || { class: SimpleReportGenerator, default_args: {} }
    end

    def self.call(...)
      new(...).call
    end

    def initialize(**kwargs)
      @report_type = kwargs[:report_type]
      @generator = self.class.for(report_type)
      @options = kwargs
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

    attr_reader :report_type, :generator, :options

    def validate_report_type
      raise InvalidReportType unless StatsReport.reports[report_type]
    end

    def generate_new_report
      generator[:class].call(**options, **generator[:default_args])
    end

    def notify_error(report_record, error)
      return unless Settings.notify_report_errors
      ActiveSupport::Notifications.instrument('call_failed.stats_report',
                                              id: report_record&.id, name: report_type, error:)
    end
  end
end
