class RemoveVatRateFromSchemes < ActiveRecord::Migration[4.2]
  def change
    remove_column :schemes, :vat_rate
  end
end
