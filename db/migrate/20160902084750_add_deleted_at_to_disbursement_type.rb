class AddDeletedAtToDisbursementType < ActiveRecord::Migration
  def change
    add_column :disbursement_types, :deleted_at, :datetime, default: nil
  end
end
