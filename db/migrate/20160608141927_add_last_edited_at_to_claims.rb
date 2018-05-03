class AddLastEditedAtToClaims < ActiveRecord::Migration[4.2]
  def change
    add_column :claims, :last_edited_at, :datetime
  end
end
