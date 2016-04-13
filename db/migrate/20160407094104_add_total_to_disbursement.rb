class AddTotalToDisbursement < ActiveRecord::Migration
  def up
    change_column_default :disbursements, :vat_amount, 0.0
    add_column :disbursements, :total, :decimal, default: 0.0
  end

  def down
    change_column_default :disbursements, :vat_amount, nil
    remove_column :disbursements, :total
  end
end
