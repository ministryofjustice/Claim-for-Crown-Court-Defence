class DropIndictmentFromClaims < ActiveRecord::Migration
  def change
    remove_column :claims, :indictment_number
  end
end
