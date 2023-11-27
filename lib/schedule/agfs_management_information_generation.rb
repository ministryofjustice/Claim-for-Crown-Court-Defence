module Schedule
  class AGFSManagementInformationGeneration
    include Sidekiq::Job

    def perform
      LogStuff.info { 'AGFS Management Information Generation started' }
      Stats::StatsReportGenerator.call(report_type: 'agfs_management_information')
      LogStuff.info { 'AGFS Management Information Generation finished' }
    rescue StandardError => e
      LogStuff.error { 'AGFS Management Information Generation error: ' + e.message }
    end
  end
end
