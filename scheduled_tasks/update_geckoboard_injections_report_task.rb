require 'chronic'

# https://github.com/ssoroka/scheduler_daemon for help
class UpdateGeckoboardInjectionsReportTask < Scheduler::SchedulerTask
  every '1d', first_at: Chronic.parse('next 4:50 am')

  def run
    log('Generating Geckoboard Injections data...')
    GeckoboardPublisher::InjectionsReport.new.publish!
  rescue StandardError => ex
    log('There was an error: ' + ex.message)
  ensure
    log('Geckboard Injections data generation finished')
  end
end
