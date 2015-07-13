class Source < ActiveRecord::Migration
  def change
    add_column :claims, :source, :string
  end
end
