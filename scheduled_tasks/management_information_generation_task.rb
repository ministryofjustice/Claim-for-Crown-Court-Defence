require 'chronic'

# https://github.com/ssoroka/scheduler_daemon for help
class ManagementInformationGenerationTask < Scheduler::SchedulerTask
  every '1d', first_at: Chronic.parse('next 3 am')

  def run
    LogStuff.info { 'Management Information Generation started' }
    Stats::StatsReportGenerator.call('management_information')
    LogStuff.info { 'Management Information Generation finished' }
  rescue StandardError => e
    LogStuff.error { 'Management Information Generation error: ' + e.message }
  end
end
