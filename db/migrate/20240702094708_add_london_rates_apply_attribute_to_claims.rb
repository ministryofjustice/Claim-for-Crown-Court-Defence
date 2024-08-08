class AddLondonRatesApplyAttributeToClaims < ActiveRecord::Migration[7.0]
  def change
    add_column :claims, :london_rates_apply, :boolean, null: true
  end
end
