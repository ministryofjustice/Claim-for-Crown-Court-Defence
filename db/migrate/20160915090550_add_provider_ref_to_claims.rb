class AddProviderRefToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :providers_ref, :string
  end
end
