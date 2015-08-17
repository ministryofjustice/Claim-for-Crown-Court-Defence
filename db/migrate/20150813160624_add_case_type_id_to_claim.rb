class AddCaseTypeIdToClaim < ActiveRecord::Migration
  def up
    add_column :claims, :case_type_id, :integer
    remove_column :claims, :case_type
  end

  def down
    add_column :claims, :case_type, :string
    remove_column :claims, :case_type_id
  end
end
