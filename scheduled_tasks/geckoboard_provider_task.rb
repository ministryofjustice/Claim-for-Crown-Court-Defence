require 'chronic'

# https://github.com/ssoroka/scheduler_daemon for help
class GeckoboardProviderTask < Scheduler::SchedulerTask
  every '1d', first_at: Chronic.parse('next 3:50 am')

  def run
    log('Geckoboard Provider data generated')
    GeckoboardPublisher::ProvidersReport.new.publish!
  rescue => ex
    log('There was an error: ' + ex.message)
  ensure
    log('Geckoboard Provider task finished')
  end
end
