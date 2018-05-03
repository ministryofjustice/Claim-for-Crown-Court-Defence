class CreateDisbursements < ActiveRecord::Migration[4.2]
  def change
    create_table :disbursements do |t|
      t.references :disbursement_type, index: true
      t.references :claim, index: true
      t.decimal :net_amount
      t.decimal :vat_amount
      t.timestamps null: true
    end
  end
end
