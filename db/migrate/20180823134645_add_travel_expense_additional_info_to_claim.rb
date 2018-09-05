class AddTravelExpenseAdditionalInfoToClaim < ActiveRecord::Migration[5.0]
  def change
    add_column :claims, :travel_expense_additional_information, :string
  end
end
