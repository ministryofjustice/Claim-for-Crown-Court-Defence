class CreateDisbursements < ActiveRecord::Migration
  def change
    create_table :disbursements do |t|
      t.references :disbursement_type, index: true, foreign_key: true
      t.references :claim, index: true, foreign_key: true
      t.decimal :net_amount
      t.decimal :vat_amount
      t.timestamps
    end
  end
end
