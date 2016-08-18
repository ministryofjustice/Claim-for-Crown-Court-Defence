class AddDeletedAtToCaseWorkers < ActiveRecord::Migration
  def change
    add_column :case_workers, :deleted_at, :datetime, default: nil
  end
end
