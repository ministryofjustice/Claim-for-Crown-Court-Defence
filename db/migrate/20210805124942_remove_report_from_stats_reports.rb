class RemoveReportFromStatsReports < ActiveRecord::Migration[6.1]
  def change
    remove_column :stats_reports, :report, :string, after: :report_name
  end
end
