class AddCloneSourceIdToClaims < ActiveRecord::Migration[4.2]
  def change
    add_column :claims, :clone_source_id, :integer
  end
end
