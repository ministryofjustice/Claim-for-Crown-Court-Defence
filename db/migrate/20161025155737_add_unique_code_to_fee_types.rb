class AddUniqueCodeToFeeTypes < ActiveRecord::Migration
  def change
    add_column :fee_types, :unique_code, :string
    add_index :fee_types, :unique_code, unique: true
  end

end
