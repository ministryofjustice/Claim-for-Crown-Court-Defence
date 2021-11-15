require 'sidekiq-scheduler'

class GeckoboardProviderScheduler
  include Sidekiq::Worker

  def perform
    LogStuff.info { "#{self.class.name} started" }
    GeckoboardPublisher::ProvidersReport.new.publish!
  rescue StandardError => e
    LogStuff.error { "#{self.class.name} error: " + e.message }
  ensure
    LogStuff.info { "#{self.class.name} finished" }
  end
end
