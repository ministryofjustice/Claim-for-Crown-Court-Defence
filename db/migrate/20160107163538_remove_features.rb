class RemoveFeatures < ActiveRecord::Migration[4.2]
  def up
    drop_table :features
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
