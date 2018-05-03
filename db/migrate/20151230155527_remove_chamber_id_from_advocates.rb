class RemoveChamberIdFromAdvocates < ActiveRecord::Migration[4.2]
  def change
    remove_column :advocates, :chamber_id
  end
end
