module Schedule
  class ReportGeneration
    include Sidekiq::Job
    include Sentry::Cron::MonitorCheckIns

    sentry_monitor_check_ins slug: 'agfs_management_information_generation'
    sentry_monitor_check_ins slug: 'agfs_management_information_v2_generation'
    # sentry_monitor_check_ins slug: 'lgfs_management_information_generation'
    # sentry_monitor_check_ins slug: 'lgfs_management_information_v2_generation'
    # sentry_monitor_check_ins slug: 'management_information_generation'
    # sentry_monitor_check_ins slug: 'management_information_v2_generation'


    def perform(report_type)
      LogStuff.info { "#{report_type.to_s.humanize} generation started" }
      Stats::StatsReportGenerator.call(report_type:)
      LogStuff.info { "#{report_type.to_s.humanize} generation finished" }
    rescue StandardError => e
      LogStuff.error { "#{report_type.to_s.humanize} generation error: #{e.message}" }
    end
  end
end
