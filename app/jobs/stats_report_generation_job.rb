class StatsReportGenerationJob < ApplicationJob
  queue_as :stats_reports

  def perform(report_type)
    begin
      LogStuff.call(:info, "Stats report job starting for report type: #{report_type}")
      Stats::StatsReportGenerator.call(report_type)
      LogStuff.call(:info, "Stats report job finished for report type: #{report_type}")
    rescue StandardError => e
      LogStuff.send(:error, "Report generation error has occured:")
      LogStuff.send(:error, "#{e.class} - #{e.message}")
      LogStuff.send(:error, "#{e.backtrace.inspect}")
    end
  end
end
