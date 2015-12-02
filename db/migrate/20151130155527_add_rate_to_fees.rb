class AddRateToFees < ActiveRecord::Migration
  def change
    add_column :fees, :rate, :decimal
  end
end
