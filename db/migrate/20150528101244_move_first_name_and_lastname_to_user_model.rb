class MoveFirstNameAndLastnameToUserModel < ActiveRecord::Migration
  def change
    remove_column :advocates, :first_name
    remove_column :advocates, :last_name
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string, index: true
  end
end
