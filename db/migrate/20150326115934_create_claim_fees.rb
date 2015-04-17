class CreateClaimFees < ActiveRecord::Migration
  def change
    create_table :claim_fees do |t|
      t.references :claim, index: true
      t.references :fee_type, index: true

      t.integer :quantity
      t.decimal :rate
      t.decimal :amount

      t.timestamps
    end
  end
end
