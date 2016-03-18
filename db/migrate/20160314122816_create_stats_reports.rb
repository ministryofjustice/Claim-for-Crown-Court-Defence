class CreateStatsReports < ActiveRecord::Migration
  def change
    create_table :stats_reports do |t|
      t.string :report_name
      t.string :report
      t.string :status
      t.datetime :started_at
      t.datetime :completed_at
    end
  end
end

