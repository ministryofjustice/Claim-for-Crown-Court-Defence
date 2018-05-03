class AddDefaultValueToAmountAssessed < ActiveRecord::Migration[4.2]
  def up
    change_column :claims, :amount_assessed, :decimal, :default => 0
  end

  def down
    change_column :claims, :amount_assessed, :decimal, :default => nil
  end
end
