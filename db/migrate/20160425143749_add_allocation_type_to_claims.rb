class AddAllocationTypeToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :allocation_type, :string
  end
end
