class DropPaperclipFieldsFromStatsReports < ActiveRecord::Migration[6.1]
  def change
    remove_column :stats_reports, :as_document_checksum, :string
    remove_column :stats_reports, :document_updated_at, :datetime
    remove_column :stats_reports, :document_file_size, :integer
    remove_column :stats_reports, :document_content_type, :string
    remove_column :stats_reports, :document_file_name, :string
  end
end
