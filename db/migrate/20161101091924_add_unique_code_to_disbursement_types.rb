class AddUniqueCodeToDisbursementTypes < ActiveRecord::Migration[4.2]
  def change
    add_column :disbursement_types, :unique_code, :string
    add_index :disbursement_types, :unique_code, unique: true
  end
end
