class RenameSubmittedAtToLastSubmittedAt < ActiveRecord::Migration[4.2]
  def change
    rename_column :claims, :submitted_at, :last_submitted_at
  end
end
