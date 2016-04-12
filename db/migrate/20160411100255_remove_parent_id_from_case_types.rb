class RemoveParentIdFromCaseTypes < ActiveRecord::Migration
  def change
    remove_column :case_types, :parent_id
  end
end
