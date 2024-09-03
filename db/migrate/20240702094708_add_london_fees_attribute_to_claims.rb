class AddLondonFeesAttributeToClaims < ActiveRecord::Migration[7.0]
  def change
    add_column :claims, :london_fees, :boolean, null: true
  end
end
