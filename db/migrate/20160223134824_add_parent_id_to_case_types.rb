class AddParentIdToCaseTypes < ActiveRecord::Migration[4.2]
  def change
    add_column :case_types, :parent_id, :integer, default: nil
  end
end
