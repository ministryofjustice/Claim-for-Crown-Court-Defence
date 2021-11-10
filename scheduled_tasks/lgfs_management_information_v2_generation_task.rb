require 'chronic'

# https://github.com/ssoroka/scheduler_daemon for help
class LgfsManagementInformationGenerationV2Task < Scheduler::SchedulerTask
  every '1d', first_at: Chronic.parse('next 2:20 am')

  def run
    LogStuff.info { 'LGFS Management Information Generation V2 started' }
    Stats::StatsReportGenerator.call('lgfs_management_information_v2')
    LogStuff.info { 'LGFS Management Information Generation V2 finished' }
  rescue StandardError => e
    LogStuff.error { 'LGFS Management Information Generation V2 error: ' + e.message }
  end
end
