module Schedule
  class AGFSManagementInformationV2Generation
    include Sidekiq::Job

    def perform
      LogStuff.info { 'AGFS Management Information Generation V2 started' }
      Stats::StatsReportGenerator.call(report_type: 'agfs_management_information_v2')
      LogStuff.info { 'AGFS Management Information Generation V2 finished' }
    rescue StandardError => e
      LogStuff.error { 'AGFS Management Information Generation V2 error: ' + e.message }
    end
  end
end
