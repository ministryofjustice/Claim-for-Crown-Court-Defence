class RemoveVatRateFromSchemes < ActiveRecord::Migration
  def change
    remove_column :schemes, :vat_rate
  end
end
