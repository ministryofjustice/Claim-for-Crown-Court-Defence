class DropAmountAssessedFromClaims < ActiveRecord::Migration[4.2]
  def up
    remove_column :claims, :amount_assessed
  end

  def down
    add_column :claims, :amount_assessed, :decimal
  end
end
