class StatsReportGenerationJob < ApplicationJob
  queue_as :stats_reports

  def perform(report_type)
    LogStuff.send(:info, "Stats report job starting for report type: #{report_type}")
    Stats::StatsReportGenerator.call(report_type)
  rescue StandardError => e
    LogStuff.send(:error, 'Report generation error has occured:')
    LogStuff.send(:error, "#{e.class} - #{e.message}")
    LogStuff.send(:error, e.backtrace.inspect.to_s)
  end
end
