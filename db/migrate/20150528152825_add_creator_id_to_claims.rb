class AddCreatorIdToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :creator_id, :integer
    add_index :claims, :creator_id
  end
end
