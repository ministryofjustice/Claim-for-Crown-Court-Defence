module Schedule
  class ReportGeneration
    include Sidekiq::Job
    include Sentry::Cron::MonitorCheckIns

    sentry_monitor_check_ins slug: 'custom_slug'


    def perform(report_type)
      raise StandardError, "This is a fake error"
    #   LogStuff.info { "#{report_type.to_s.humanize} generation started" }
    #   Stats::StatsReportGenerator.call(report_type:)
    #   LogStuff.info { "#{report_type.to_s.humanize} generation finished" }
    # rescue StandardError => e
    #   LogStuff.error { "#{report_type.to_s.humanize} generation error: #{e.message}" }
    end
  end
end
