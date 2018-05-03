class AddPaidAtToClaims < ActiveRecord::Migration[4.2]
  def change
    add_column :claims, :paid_at, :datetime
  end
end
