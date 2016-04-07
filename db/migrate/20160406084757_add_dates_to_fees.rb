class AddDatesToFees < ActiveRecord::Migration
  def change
    add_column :fees, :warrant_issued_date, :date
    add_column :fees, :warrant_executed_date, :date
  end
end
