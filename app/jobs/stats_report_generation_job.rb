class StatsReportGenerationJob < ApplicationJob
  queue_as :stats_reports

  def perform(report_type)
    LogStuff.send(:info, "Stats report job starting for report type: #{report_type}")
    Stats::StatsReportGenerator.call(report_type)
  end
end
