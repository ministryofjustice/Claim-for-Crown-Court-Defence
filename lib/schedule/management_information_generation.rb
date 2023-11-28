module Schedule
  class ManagementInformationGeneration
    include Sidekiq::Job

    def perform
      LogStuff.info { 'Management Information Generation started' }
      Stats::StatsReportGenerator.call(report_type: 'management_information')
      LogStuff.info { 'Management Information Generation finished' }
    rescue StandardError => e
      LogStuff.error { 'Management Information Generation error: ' + e.message }
    end
  end
end
