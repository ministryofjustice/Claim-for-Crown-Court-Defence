class RemoveSchemeIdFromClaims < ActiveRecord::Migration
  def change
    remove_column :claims, :scheme_id
  end
end
