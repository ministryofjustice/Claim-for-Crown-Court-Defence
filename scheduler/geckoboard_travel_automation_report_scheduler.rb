require 'sidekiq-scheduler'

class GeckoboardTravelAutomationReportScheduler
  include Sidekiq::Worker

  def perform
    LogStuff.info { "#{self.class.name} started" }
    gp = GeckoboardPublisher::TravelAutomationReport.new
    gp.publish!
    gp.push!
  rescue StandardError => e
    LogStuff.error { "#{self.class.name} error: " + e.message }
  ensure
    LogStuff.info { "#{self.class.name} finished" }
end
