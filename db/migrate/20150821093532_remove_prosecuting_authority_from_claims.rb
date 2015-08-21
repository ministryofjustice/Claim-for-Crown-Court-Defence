class RemoveProsecutingAuthorityFromClaims < ActiveRecord::Migration
  def change
    remove_column :claims, :prosecuting_authority
  end
end
