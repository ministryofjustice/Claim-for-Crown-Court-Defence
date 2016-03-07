class AddParentIdToCaseTypes < ActiveRecord::Migration
  def change
    add_column :case_types, :parent_id, :integer, default: nil
  end
end
