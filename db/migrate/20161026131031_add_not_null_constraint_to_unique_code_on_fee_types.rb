class AddNotNullConstraintToUniqueCodeOnFeeTypes < ActiveRecord::Migration
  def up
    change_column :fee_types, :unique_code, :string, null: false
  end

  def down
    change_column :fee_types, :unique_code, :string, null: true
  end
end
