class AddDisbursementTypeIdToFees < ActiveRecord::Migration[4.2]
  def change
    add_column :fees, :disbursement_type_id, :integer
  end
end
