class AddDisbursementsTotalToClaim < ActiveRecord::Migration[4.2]
  def change
    add_column :claims, :disbursements_total, :decimal, default: 0.0
  end
end
