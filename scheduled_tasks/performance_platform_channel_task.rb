# https://github.com/ssoroka/scheduler_daemon for help
class PerformancePlatformChannelTask < Scheduler::SchedulerTask
  cron '40 3 * * 1' # 3:40 on Monday
  class ReportNotActivated < RuntimeError; end
  def run
    raise ReportNotActivated unless ENV['PERF_PLAT_TBC_TOKEN']
    log('Performance Platform - Channel Task started')
    tbc = Reports::PerformancePlatform::TransactionsByChannel.new(Date.today.beginning_of_week - 7.days)
    tbc.populate_data
    tbc.publish!
  rescue ReportNotActivated
    log('Performance Platform - Channel Task skipped as `PERF_PLAT_TBC_TOKEN` not found in ENV')
  rescue StandardError => ex
    log('There was an error: ' + ex.message)
  ensure
    log('Performance Platform - Channel Task finished')
  end
end
