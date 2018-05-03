class RemoveSchemeIdFromClaims < ActiveRecord::Migration[4.2]
  def change
    remove_column :claims, :scheme_id
  end
end
