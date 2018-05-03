class AddRateToFees < ActiveRecord::Migration[4.2]
  def change
    add_column :fees, :rate, :decimal
  end
end
