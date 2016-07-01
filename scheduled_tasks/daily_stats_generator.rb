require 'chronic'

# https://github.com/ssoroka/scheduler_daemon for help
class DailyStatsGenerator < Scheduler::SchedulerTask

  every '1d', first_at: Chronic.parse('next 4 am')

  def run
    log('Daily stats generation started')
    Stats::Collector::ClaimSubmissionsCollector.new(Date.yesterday).collect
    Stats::Collector::MultiSessionSubmissionCollector.new(Date.yesterday).collect
    Stats::Collector::InfoRequestCountCollector.new(Date.yesterday).collect
    Stats::Collector::TimeFromRejectToAuthCollector.new(Date.yesterday).collect
  rescue => ex
    log('There was an error: ' + ex.message)
  ensure
    log('Daily stats generation finished')
  end
end
