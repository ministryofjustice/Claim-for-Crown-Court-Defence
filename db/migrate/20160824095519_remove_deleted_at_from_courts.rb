class RemoveDeletedAtFromCourts < ActiveRecord::Migration
  def change
    remove_column :courts, :deleted_at
  end
end
