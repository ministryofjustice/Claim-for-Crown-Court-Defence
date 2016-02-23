class RemoveFeeCategories < ActiveRecord::Migration
  def up
    remove_column :fee_types, :fee_category_id
    drop_table :fee_categories
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
