class RemoveSchemes < ActiveRecord::Migration[4.2]
  def change
    drop_table :schemes
  end
end
