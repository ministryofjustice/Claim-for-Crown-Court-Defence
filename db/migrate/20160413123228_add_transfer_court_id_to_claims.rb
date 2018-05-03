class AddTransferCourtIdToClaims < ActiveRecord::Migration[4.2]
  def change
    add_column :claims, :transfer_court_id, :integer
  end
end
