class AddFormIdToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :form_id, :string
    add_index :claims, :form_id
  end
end
