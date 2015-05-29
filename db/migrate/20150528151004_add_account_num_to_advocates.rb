class AddAccountNumToAdvocates < ActiveRecord::Migration
  def change
    add_column :advocates, :account_number, :string
    add_index  :advocates, :account_number

  end
end
