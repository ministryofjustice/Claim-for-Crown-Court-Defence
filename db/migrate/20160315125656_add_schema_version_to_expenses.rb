class AddSchemaVersionToExpenses < ActiveRecord::Migration
  def up
    add_column :expenses, :schema_version, :integer
    execute 'UPDATE expenses SET schema_version = 1'
  end

  def down
    remove_column :expenses, :schema_version
  end
end
