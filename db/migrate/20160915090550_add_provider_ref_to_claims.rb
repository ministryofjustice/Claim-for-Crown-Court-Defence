class AddProviderRefToClaims < ActiveRecord::Migration[4.2]
  def change
    add_column :claims, :providers_ref, :string
  end
end
