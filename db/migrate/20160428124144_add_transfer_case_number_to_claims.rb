class AddTransferCaseNumberToClaims < ActiveRecord::Migration[4.2]
  def change
    add_column :claims, :transfer_case_number, :string
    add_index :claims, :transfer_case_number
  end
end
