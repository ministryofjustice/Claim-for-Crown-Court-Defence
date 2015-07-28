class RemoveRateFromFees < ActiveRecord::Migration
  def change
    remove_column :fees, :rate, :decimal
  end
end
