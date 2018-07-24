require 'chronic'

# https://github.com/ssoroka/scheduler_daemon for help
class ManagementInformationGenerationTask < Scheduler::SchedulerTask
  every '1d', first_at: Chronic.parse('next 3 am')

  def run
    log('Management Information Generation started')
    Stats::StatsReportGenerator.call('management_information')
  rescue StandardError => err
    log('There was an error: ' + err.message)
  ensure
    log('Management Information Generation finished')
  end
end
