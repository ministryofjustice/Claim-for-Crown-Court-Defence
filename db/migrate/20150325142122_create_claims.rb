class CreateClaims < ActiveRecord::Migration
  def change
    create_table :claims do |t|
      t.text :additional_information
      t.boolean :vat_required
      t.string :state, index: true

      t.references :advocate, index: true
      t.references :court, index: true

      t.timestamps
    end
  end
end
