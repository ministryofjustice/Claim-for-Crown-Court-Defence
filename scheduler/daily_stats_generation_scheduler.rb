require 'sidekiq-scheduler'

class DailyStatsGenerationScheduler
  include Sidekiq::Worker

  def perform
    LogStuff.info { "#{self.class.name} started" }

    collectors.each do |klass|
      LogStuff.info { "#{klass} started" }
      begin
        klass.new(date).collect
      rescue StandardError => e
        LogStuff.error { "#{e.class} error: " + e.message }
      ensure
        LogStuff.info { "#{klass} finished" }
      end
    end
    LogStuff.info { "#{self.class.name} finished" }
  end

  private

  def date
    Date.yesterday
  end

  def collectors
    [
      Stats::Collector::ClaimCreationSourceCollector,
      Stats::Collector::ClaimSubmissionsCollector,
      Stats::Collector::MultiSessionSubmissionCollector,
      Stats::Collector::InfoRequestCountCollector,
      Stats::Collector::CompletionRateCollector,
      Stats::Collector::TimeToCompletionCollector,
      Stats::Collector::ClaimRedeterminationsCollector,
      Stats::Collector::MoneyToDateCollector,
      Stats::Collector::MoneyClaimedPerMonthCollector
    ]
  end
end
