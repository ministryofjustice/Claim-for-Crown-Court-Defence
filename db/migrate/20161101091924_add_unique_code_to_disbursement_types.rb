class AddUniqueCodeToDisbursementTypes < ActiveRecord::Migration
  def change
    add_column :disbursement_types, :unique_code, :string
    add_index :disbursement_types, :unique_code, unique: true
  end
end
