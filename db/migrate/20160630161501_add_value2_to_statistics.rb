class AddValue2ToStatistics < ActiveRecord::Migration
  def change
    add_column :statistics, :value_2, :integer, default: 0
  end
end
