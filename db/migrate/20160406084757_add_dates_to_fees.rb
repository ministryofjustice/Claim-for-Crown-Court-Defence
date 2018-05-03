class AddDatesToFees < ActiveRecord::Migration[4.2]
  def change
    add_column :fees, :warrant_issued_date, :date
    add_column :fees, :warrant_executed_date, :date
  end
end
