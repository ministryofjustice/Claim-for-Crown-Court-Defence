class AddSubTypeIdToFees < ActiveRecord::Migration
  def change
    add_column :fees, :sub_type_id, :integer
  end
end
