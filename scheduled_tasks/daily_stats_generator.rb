require 'chronic'

# https://github.com/ssoroka/scheduler_daemon for help
class DailyStatsGenerator < Scheduler::SchedulerTask

  every '1d', first_at: Chronic.parse('next 5 am')

  def run
    log('Daily stats generation started')

    collectors.each do |klass|
      klass.new(date).collect
    end
  rescue => ex
    log('There was an error: ' + ex.message)
  ensure
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
      Stats::Collector::TimeFromRejectToAuthCollector
    ]
  end
end
