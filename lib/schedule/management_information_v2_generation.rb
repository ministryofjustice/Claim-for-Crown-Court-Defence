module Schedule
  class ManagementInformationV2Generation
    include Sidekiq::Job

    def perform
      LogStuff.info { 'Management Information Generation V2 started' }
      Stats::StatsReportGenerator.call(report_type: 'management_information_v2')
      LogStuff.info { 'Management Information Generation V2 finished' }
    rescue StandardError => e
      LogStuff.error { 'Management Information Generation V2 error: ' + e.message }
    end
  end
end
