class AddTypeToFeeType < ActiveRecord::Migration
  def up
    add_column :fee_types, :type, :string
  end

  def down
    remove_column :fee_types, :type
  end
end
