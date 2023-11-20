require 'chronic'

# https://github.com/ssoroka/scheduler_daemon for help
class AGFSManagementInformationGenerationTask < Scheduler::SchedulerTask
  every '1d', first_at: Chronic.parse('next 2:00 am')

  def run
    LogStuff.info { 'AGFS Management Information Generation started' }
    Stats::StatsReportGenerator.call(report_type: 'agfs_management_information')
    LogStuff.info { 'AGFS Management Information Generation finished' }
  rescue StandardError => e
    LogStuff.error { 'AGFS Management Information Generation error: ' + e.message }
  end
end
