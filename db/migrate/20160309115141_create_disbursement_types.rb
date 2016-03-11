class CreateDisbursementTypes < ActiveRecord::Migration
  def change
    create_table :disbursement_types do |t|
      t.string :name
      t.timestamps
    end

    add_index :disbursement_types, :name
  end
end
