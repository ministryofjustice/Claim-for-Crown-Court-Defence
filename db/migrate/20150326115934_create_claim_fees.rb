class CreateClaimFees < ActiveRecord::Migration
  def change
    create_table :claim_fees do |t|
      t.references :claim, index: true
      t.references :fee, index: true

      t.timestamps
    end
  end
end
