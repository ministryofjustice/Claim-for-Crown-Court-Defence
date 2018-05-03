class AddMigrationSpikesTable < ActiveRecord::Migration[4.2]
  def change
    add_column :courts, :deleted_at, :datetime, default: nil
  end
end



# result = ActiveRecord::Base.connection.execute('select * from schema_migrations order by version desc limit 1')
# result[result.ntuples - 1]

