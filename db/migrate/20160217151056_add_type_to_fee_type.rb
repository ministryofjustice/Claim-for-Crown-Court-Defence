class AddTypeToFeeType < ActiveRecord::Migration[4.2]
  def up
    add_column :fee_types, :type, :string
  end

  def down
    remove_column :fee_types, :type
  end
end
