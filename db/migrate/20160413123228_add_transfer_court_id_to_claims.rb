class AddTransferCourtIdToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :transfer_court_id, :integer
  end
end
