class AddAccountNumToAdvocates < ActiveRecord::Migration[4.2]
  def change
    add_column :advocates, :account_number, :string
    add_index  :advocates, :account_number

  end
end
