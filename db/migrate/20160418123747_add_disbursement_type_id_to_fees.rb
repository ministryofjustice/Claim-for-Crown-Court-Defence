class AddDisbursementTypeIdToFees < ActiveRecord::Migration
  def change
    add_column :fees, :disbursement_type_id, :integer
  end
end
