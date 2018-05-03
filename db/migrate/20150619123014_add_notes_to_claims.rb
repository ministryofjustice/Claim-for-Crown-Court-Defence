class AddNotesToClaims < ActiveRecord::Migration[4.2]
  def change
    add_column :claims, :notes, :text
  end
end
