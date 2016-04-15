class AddCaseNumbersToFees < ActiveRecord::Migration
  def change
    add_column :fees, :case_numbers, :string
  end
end
