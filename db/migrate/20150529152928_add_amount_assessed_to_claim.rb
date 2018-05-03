class AddAmountAssessedToClaim < ActiveRecord::Migration[4.2]
  def change
    add_column :claims, :amount_assessed, :decimal
  end
end
