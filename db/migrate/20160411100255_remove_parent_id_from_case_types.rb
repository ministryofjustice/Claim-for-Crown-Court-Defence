class RemoveParentIdFromCaseTypes < ActiveRecord::Migration[4.2]
  def change
    remove_column :case_types, :parent_id
  end
end
