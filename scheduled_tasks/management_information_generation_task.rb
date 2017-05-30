require 'chronic'

# https://github.com/ssoroka/scheduler_daemon for help
class ManagementInformationGenerationTask < Scheduler::SchedulerTask
  every '1d', first_at: Chronic.parse('next 3 am')

  def run
    log('Management Information Generation started')
    Stats::ManagementInformationGenerator.new.run
  rescue => ex
    log('There was an error: ' + ex.message)
  ensure
    log('Management Information Generation finished')
  end
end
