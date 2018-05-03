class RemoveDeletedAtFromCourts < ActiveRecord::Migration[4.2]
  def change
    remove_column :courts, :deleted_at
  end
end
