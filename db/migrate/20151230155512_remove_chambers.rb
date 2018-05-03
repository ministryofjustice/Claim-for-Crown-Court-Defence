class RemoveChambers < ActiveRecord::Migration[4.2]
  def change
    drop_table :chambers
  end
end
