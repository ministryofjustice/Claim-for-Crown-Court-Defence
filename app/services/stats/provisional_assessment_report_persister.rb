module Stats
  class ProvisionalAssessmentReportPersister
    def self.call(options = {})
      new(options).call
    end

    def initialize(options = {})
      @report_name = Reports::ProvisionalAssessments::NAME
      @options = options
    end

    def call
      StatsReport.clean_up(report_name)
      return if StatsReport.generation_in_progress?(report_name)
      report_record = Stats::StatsReport.record_start(report_name)
      report_contents = generate_new_report
      report_record.write_report(report_contents)
    rescue StandardError => err
      report_contents = "#{err.class} - #{err.message} \n #{err.backtrace}"
      report_record.write_error(report_contents)
      notify_error(report_record, err)
      raise
    end

    private

    attr_reader :report_name, :options

    def generate_new_report
      ProvisionalAssessmentReportGenerator.call(options)
    end

    def notify_error(report_record, error)
      return unless Settings.notify_report_errors
      ActiveSupport::Notifications.instrument 'call_failed.stats_report',
                                              id: report_record.id, name: report_name, error: error
    end
  end
end
