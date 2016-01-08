class RemoveFeatures < ActiveRecord::Migration
  def up
    drop_table :features
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
