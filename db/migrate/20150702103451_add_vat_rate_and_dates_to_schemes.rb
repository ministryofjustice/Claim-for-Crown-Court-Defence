class AddVatRateAndDatesToSchemes < ActiveRecord::Migration[4.2]
  def change
    add_column :schemes, :vat_rate, :float
    add_column :schemes, :start_date, :datetime
    add_column :schemes, :end_date, :datetime
  end
end
