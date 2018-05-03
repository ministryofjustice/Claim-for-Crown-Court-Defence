class AddCmsNumberToClaims < ActiveRecord::Migration[4.2]
  def change
    add_column :claims, :cms_number, :string
    add_index :claims, :cms_number
  end
end
