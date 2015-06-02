class AddPaymentStatusToClaim < ActiveRecord::Migration
  def change
    add_column :claims, :payment_status, :string, default: 'unassessed'
  end
end
