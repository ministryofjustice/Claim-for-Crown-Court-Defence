require 'chronic'

# https://github.com/ssoroka/scheduler_daemon for help
class ManagementInformationGenerationV2Task < Scheduler::SchedulerTask
  every '1d', first_at: Chronic.parse('next 2:50 am')

  def run
    LogStuff.info { 'AGFS Management Information Generation V2 started' }
    Stats::StatsReportGenerator.call('management_information_v2')
    LogStuff.info { 'AGFS Management Information Generation V2 finished' }
  rescue StandardError => e
    LogStuff.error { 'AGFS Management Information Generation V2 error: ' + e.message }
  end
end
