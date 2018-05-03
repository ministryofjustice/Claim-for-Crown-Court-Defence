class RemoveDisbursementTypeIdFromFees < ActiveRecord::Migration[4.2]
  def up
    remove_column :fees, :disbursement_type_id
  end
  def down
    add_column :fees, :disbursement_type_id, :integer
  end
end
