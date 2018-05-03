class RemoveProsecutingAuthorityFromClaims < ActiveRecord::Migration[4.2]
  def change
    remove_column :claims, :prosecuting_authority
  end
end
