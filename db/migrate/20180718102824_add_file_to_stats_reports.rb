class AddFileToStatsReports < ActiveRecord::Migration[5.0]
  def up
    # Paperclip attachment are created using:
    #   t.attachment :document
    # This requires the paperclip gem, which has now been removed, so it is replaced by:
    add_column :stats_reports, :document_file_name, :string
    add_column :stats_reports, :document_content_type, :string
    add_column :stats_reports, :document_file_size, :integer
    add_column :stats_reports, :document_updated_at, :datetime
  end

  def down
    drop_column :stats_reports, :document_file_name
    drop_column :stats_reports, :document_content_type
    drop_column :stats_reports, :document_file_size
    drop_column :stats_reports, :document_updated_at
  end
end
