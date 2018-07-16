class StatsReportGenerationJob < ApplicationJob
  queue_as :stats_reports

  def perform(report_type)
    Stats::StatsReportGenerator.call(report_type)
  end
end
