class AddAmountAssessedToClaim < ActiveRecord::Migration
  def change
    add_column :claims, :amount_assessed, :decimal
  end
end
