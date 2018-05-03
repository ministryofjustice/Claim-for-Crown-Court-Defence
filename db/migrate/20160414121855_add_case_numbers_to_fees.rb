class AddCaseNumbersToFees < ActiveRecord::Migration[4.2]
  def change
    add_column :fees, :case_numbers, :string
  end
end
