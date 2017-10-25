require 'chronic'

# https://github.com/ssoroka/scheduler_daemon for help
class DailyStatsGenerator < Scheduler::SchedulerTask
  every '1d', first_at: Chronic.parse('next 5 am')

  def run
    log('Daily stats generation started')

    collectors.each do |klass|
      log("Starting #{klass}")
      begin
        klass.new(date).collect
      rescue StandardError => err
        log("ERROR: #{err.class} #{err.message}")
      end
    end
    log('Daily stats generation finished')
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
      Stats::Collector::TimeFromRejectToAuthCollector,
      Stats::Collector::CompletionRateCollector,
      Stats::Collector::TimeToCompletionCollector,
      Stats::Collector::ClaimRedeterminationsCollector,
      Stats::Collector::MoneyToDateCollector,
      Stats::Collector::MoneyClaimedPerMonthCollector
    ]
  end
end
