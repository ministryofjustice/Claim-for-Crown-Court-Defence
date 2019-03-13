# https://github.com/ssoroka/scheduler_daemon for help
class PerformancePlatformCostPerTransactionTask < Scheduler::SchedulerTask
  cron '15 4 1 1/3 *' # 04:15 on the first of every quarter
  class ReportNotActivated < RuntimeError; end
  def run
    raise ReportNotActivated unless ENV['PERF_PLAT_QV_TOKEN']
    log('Performance Platform - Cost Per Transaction Task started')
    cpt = Reports::PerformancePlatform::QuarterlyVolume.new(Date.yesterday.beginning_of_quarter)
    cpt.populate_data
    cpt.publish!
  rescue ReportNotActivated
    log('Performance Platform - Cost Per Transaction Task skipped as `PERF_PLAT_QV_TOKEN` not found in ENV')
  rescue StandardError => ex
    log('There was an error: ' + ex.message)
  ensure
    log('Performance Platform - Cost Per Transaction Task finished')
  end
end
