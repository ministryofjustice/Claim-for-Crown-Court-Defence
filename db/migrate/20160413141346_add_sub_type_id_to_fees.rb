class AddSubTypeIdToFees < ActiveRecord::Migration[4.2]
  def change
    add_column :fees, :sub_type_id, :integer
  end
end
