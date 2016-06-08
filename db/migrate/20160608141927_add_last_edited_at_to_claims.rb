class AddLastEditedAtToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :last_edited_at, :datetime
  end
end
