class AddVatRatesTable < ActiveRecord::Migration[4.2]
  def change
    create_table :vat_rates do |t|
      t.integer :rate_base_points
      t.date :effective_date

      t.timestamps null: true
    end
  end
end
