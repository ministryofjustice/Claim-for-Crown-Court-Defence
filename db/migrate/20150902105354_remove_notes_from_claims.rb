class RemoveNotesFromClaims < ActiveRecord::Migration
  def change
    remove_column :claims, :notes
  end
end
