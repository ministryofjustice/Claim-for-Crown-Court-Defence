require 'sidekiq-scheduler'

class AgfsManagementInformationV2GenerationScheduler
  include Sidekiq::Worker

  def perform
    LogStuff.info { "#{self.class.name} started" }
    Stats::StatsReportGenerator.call('agfs_management_information_v2')
    LogStuff.info { "#{self.class.name} finished" }
  rescue StandardError => e
    LogStuff.error { "#{self.class.name} error: " + e.message }
  ensure
    LogStuff.info { "#{self.class.name} finished" }
  end
end
