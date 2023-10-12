require 'chronic'

# https://github.com/ssoroka/scheduler_daemon for help
class LGFSManagementInformationGenerationTask < Scheduler::SchedulerTask
  every '1d', first_at: Chronic.parse('next 2:30 am')

  def run
    LogStuff.info { 'LGFS Management Information Generation started' }
    Stats::StatsReportGenerator.call(report_type: 'lgfs_management_information')
    LogStuff.info { 'LGFS Management Information Generation finished' }
  rescue StandardError => e
    LogStuff.error { 'LGFS Management Information Generation error: ' + e.message }
  end
end
