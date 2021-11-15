require 'sidekiq-scheduler'

class LgfsManagementInformationGenerationScheduler
  include Sidekiq::Worker

  def perform
    LogStuff.info { "#{self.class.name} started" }
    Stats::StatsReportGenerator.call('lgfs_management_information')
  rescue StandardError => e
    LogStuff.error { "#{self.class.name} error: " + e.message }
  ensure
    LogStuff.info { "#{self.class.name} finished" }
  end
end
