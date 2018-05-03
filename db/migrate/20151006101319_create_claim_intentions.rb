class CreateClaimIntentions < ActiveRecord::Migration[4.2]
  def change
    create_table :claim_intentions do |t|
      t.string :form_id

      t.timestamps null: false
    end
    add_index :claim_intentions, :form_id
  end
end
