class AddPaidAtToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :paid_at, :datetime
  end
end
