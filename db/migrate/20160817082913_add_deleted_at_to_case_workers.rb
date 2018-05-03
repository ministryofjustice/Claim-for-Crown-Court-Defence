class AddDeletedAtToCaseWorkers < ActiveRecord::Migration[4.2]
  def change
    add_column :case_workers, :deleted_at, :datetime, default: nil
  end
end
