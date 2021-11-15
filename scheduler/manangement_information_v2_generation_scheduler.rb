require 'sidekiq-scheduler'

class ManagementInformationV2GenerationScheduler
  include Sidekiq::Worker

  def perform
    LogStuff.info { "#{self.class.name} started" }
    Stats::StatsReportGenerator.call('management_information_v2')
  rescue StandardError => e
    LogStuff.error { "#{self.class.name} error: " + e.message }
  ensure
    LogStuff.info { "#{self.class.name} finished" }
  end
end
