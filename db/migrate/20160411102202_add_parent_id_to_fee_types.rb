class AddParentIdToFeeTypes < ActiveRecord::Migration
  def change
    add_column :fee_types, :parent_id, :integer, default: nil
  end
end
