class CreateDisbursementTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :disbursement_types do |t|
      t.string :name
      t.timestamps null: true
    end

    add_index :disbursement_types, :name
  end
end
