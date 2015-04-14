class CreateClaims < ActiveRecord::Migration
  def change
    create_table :claims do |t|
      t.text :additional_information
      t.boolean :vat_required
      t.string :state, index: true
      t.string :case_type, index: true
      t.string :offence_class, index: true
      t.datetime :submitted_at
      t.string :case_number, index: true

      t.decimal :fees_total, default: 0
      t.decimal :expenses_total, default: 0
      t.decimal :total, default: 0

      t.references :advocate, index: true
      t.references :court, index: true

      t.timestamps
    end
  end
end
