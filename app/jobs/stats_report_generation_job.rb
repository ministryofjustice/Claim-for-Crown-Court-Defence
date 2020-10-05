class StatsReportGenerationJob < ApplicationJob
  queue_as :stats_reports

  def perform(report_type)
    LogStuff.send(:info, class: self.class.name, action: 'perform') do
      "Stats report job starting for report type: #{report_type}"
    end
    Stats::StatsReportGenerator.call(report_type)
  end
end
