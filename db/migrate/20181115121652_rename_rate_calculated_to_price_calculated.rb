# Make name more generic as used for calculated rates and amounts
class RenameRateCalculatedToPriceCalculated < ActiveRecord::Migration[5.0]
  def change
    rename_column :fees, :rate_calculated, :price_calculated
  end
end
