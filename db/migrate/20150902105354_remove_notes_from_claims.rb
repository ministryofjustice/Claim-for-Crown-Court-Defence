class RemoveNotesFromClaims < ActiveRecord::Migration[4.2]
  def change
    remove_column :claims, :notes
  end
end
