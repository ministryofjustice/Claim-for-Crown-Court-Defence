class AddParentIdToFeeTypes < ActiveRecord::Migration[4.2]
  def change
    add_column :fee_types, :parent_id, :integer, default: nil
  end
end
