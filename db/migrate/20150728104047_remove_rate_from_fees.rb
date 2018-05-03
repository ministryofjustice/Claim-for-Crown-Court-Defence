class RemoveRateFromFees < ActiveRecord::Migration[4.2]
  def change
    remove_column :fees, :rate, :decimal
  end
end
