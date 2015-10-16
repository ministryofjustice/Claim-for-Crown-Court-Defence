class RenameSubmittedAtToLastSubmittedAt < ActiveRecord::Migration
  def change
    rename_column :claims, :submitted_at, :last_submitted_at
  end
end
