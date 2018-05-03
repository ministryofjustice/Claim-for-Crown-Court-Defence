class AlterTableDatesAttended < ActiveRecord::Migration[4.2]
  def change
    remove_column    :dates_attended, :fee_id, :integer
    add_reference    :dates_attended, :attended_item, polymorphic: true

    add_index :dates_attended, [:attended_item_id, :attended_item_type]
  end
end
