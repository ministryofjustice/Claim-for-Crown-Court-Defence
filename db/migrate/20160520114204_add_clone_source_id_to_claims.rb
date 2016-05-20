class AddCloneSourceIdToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :clone_source_id, :integer
  end
end
