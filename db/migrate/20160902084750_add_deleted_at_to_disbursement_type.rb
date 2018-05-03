class AddDeletedAtToDisbursementType < ActiveRecord::Migration[4.2]
  def change
    add_column :disbursement_types, :deleted_at, :datetime, default: nil
  end
end
