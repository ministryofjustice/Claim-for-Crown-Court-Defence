class RemoveChamberIdFromAdvocates < ActiveRecord::Migration
  def change
    remove_column :advocates, :chamber_id
  end
end
