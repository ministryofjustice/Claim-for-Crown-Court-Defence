class AddCircleTestToCaseTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :case_types, :circle_test, :string
  end
end
