class AddUniqueCodeToFeeTypes < ActiveRecord::Migration[4.2]
  def change
    add_column :fee_types, :unique_code, :string
    add_index :fee_types, :unique_code, unique: true
  end

end
