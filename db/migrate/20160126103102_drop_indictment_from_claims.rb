class DropIndictmentFromClaims < ActiveRecord::Migration[4.2]
  def change
    remove_column :claims, :indictment_number
  end
end
