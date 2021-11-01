class StatsReportGenerationJob < ApplicationJob
  queue_as :stats_reports

  def perform(**kwargs)
    LogStuff.info(class: self.class.name, action: 'perform', report_type: kwargs[:report_type]) do
      "Stats report job starting for report type: #{kwargs[:report_type]}"
    end

    Stats::StatsReportGenerator.call(kwargs)

    LogStuff.info(class: self.class.name, action: 'perform', report_type: kwargs[:report_type]) do
      "Stats report job finished for report type: #{kwargs[:report_type]}"
    end
  end
end
