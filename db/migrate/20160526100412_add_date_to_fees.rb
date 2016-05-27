class AddDateToFees < ActiveRecord::Migration
  def change
    add_column :fees, :date, :date
  end
end
