require 'chronic'

# https://github.com/ssoroka/scheduler_daemon for help
class ManagementInformationGenerationTask < Scheduler::SchedulerTask

  # change the frequency once we are sure it is working
  # every '1d', first_at: Chronic.parse('next 3 am')
  every '15m'

  def run
    log('Management Information Generation started')

    Stats::ManagementInformationGenerator.new.run

    log('Management Information Generation finished')
  end
end
