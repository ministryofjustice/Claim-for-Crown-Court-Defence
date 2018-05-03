class AddAllocationTypeToClaims < ActiveRecord::Migration[4.2]
  def change
    add_column :claims, :allocation_type, :string
  end
end
