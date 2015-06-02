class AddDefaultValueToAmountAssessed < ActiveRecord::Migration
  def up
    change_column :claims, :amount_assessed, :decimal, :default => 0
  end

  def down
    change_column :claims, :amount_assessed, :decimal, :default => nil
  end
end
