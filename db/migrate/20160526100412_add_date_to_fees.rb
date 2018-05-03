class AddDateToFees < ActiveRecord::Migration[4.2]
  def change
    add_column :fees, :date, :date
  end
end
