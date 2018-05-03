class AddSchemaVersionToExpenses < ActiveRecord::Migration[4.2]
  def up
    add_column :expenses, :schema_version, :integer
    execute 'UPDATE expenses SET schema_version = 1'
  end

  def down
    remove_column :expenses, :schema_version
  end
end
