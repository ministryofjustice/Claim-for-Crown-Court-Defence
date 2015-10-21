class RemoveSchemes < ActiveRecord::Migration
  def change
    drop_table :schemes
  end
end
