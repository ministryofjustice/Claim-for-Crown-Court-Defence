class AddRateCalculatedToFees < ActiveRecord::Migration[5.0]
  def change
    add_column :fees, :rate_calculated, :boolean, default: false
  end
end
