# https://github.com/ssoroka/scheduler_daemon for help
class PerformancePlatformCostPerTransactionTask < Scheduler::SchedulerTask
  cron '15 4 2,3 1,4,7,10 *' # 04:15 on the 2nd and third of every quarter
  class ReportNotActivated < RuntimeError; end
  def run
    raise ReportNotActivated unless ENV['PERF_PLAT_QV_TOKEN']
    log('Performance Platform - Cost Per Transaction Task started')
    cpt = Reports::PerformancePlatform::QuarterlyVolume.new(Date.today.beginning_of_quarter - 3.months)
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
