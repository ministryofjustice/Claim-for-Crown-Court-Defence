class AddFileToStatsReports < ActiveRecord::Migration[5.0]
  def up
    add_attachment :stats_reports, :document
  end

  def down
    remove_attachment :stats_reports, :document
  end
end
