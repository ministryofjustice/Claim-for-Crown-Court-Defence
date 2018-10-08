require 'chronic'

# https://github.com/ssoroka/scheduler_daemon for help
class GeckoboardTravelAutomationReportTask < Scheduler::SchedulerTask
  every '1d', first_at: Chronic.parse('next 4:40 am')

  def run
    log('Generating Geckoboard travel automation data...')
    gp = GeckoboardPublisher::TravelAutomationReport.new
    gp.publish!
    gp.push!
  rescue StandardError => ex
    log('There was an error: ' + ex.message)
  ensure
    log('Geckoboard travel automation data generation finished')
  end
end
