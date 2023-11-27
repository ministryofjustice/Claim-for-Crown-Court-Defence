module Schedule
  class LGFSManagementInformationV2Generation
    include Sidekiq::Job

    def perform
      LogStuff.info { 'LGFS Management Information Generation V2 started' }
      Stats::StatsReportGenerator.call(report_type: 'lgfs_management_information_v2')
      LogStuff.info { 'LGFS Management Information Generation V2 finished' }
    rescue StandardError => e
      LogStuff.error { 'LGFS Management Information Generation V2 error: ' + e.message }
    end
  end
end
