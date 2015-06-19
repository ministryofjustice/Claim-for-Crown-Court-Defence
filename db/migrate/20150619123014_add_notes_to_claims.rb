class AddNotesToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :notes, :text
  end
end
