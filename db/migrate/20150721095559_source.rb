class Source < ActiveRecord::Migration[4.2]
  def change
    add_column :claims, :source, :string
  end
end
