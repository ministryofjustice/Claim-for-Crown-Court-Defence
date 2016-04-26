class AddDisbursementsToDeterminations < ActiveRecord::Migration
  def up
    add_column :determinations, :disbursements, :decimal, default: 0.0
    change_column_default :determinations, :fees, 0.0
    change_column_default :determinations, :expenses, 0.0
  end

  def down
    remove_column :determinations, :disbursements
    change_column_default :determinations, :fees, nil
    change_column_default :determinations, :expenses, nil
  end
end
