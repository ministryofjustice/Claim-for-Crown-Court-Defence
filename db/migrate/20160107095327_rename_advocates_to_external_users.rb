class RenameAdvocatesToExternalUsers < ActiveRecord::Migration[4.2]
  def self.up
    rename_table :advocates, :external_users
  end

 def self.down
    rename_table :external_users, :advocates
 end
end
