class RemoveDisbursementTypeIdFromFees < ActiveRecord::Migration
  def up
    remove_column :fees, :disbursement_type_id
  end
  def down
    add_column :fees, :disbursement_type_id, :integer
  end
end
