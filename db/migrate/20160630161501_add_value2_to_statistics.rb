class AddValue2ToStatistics < ActiveRecord::Migration[4.2]
  def change
    add_column :statistics, :value_2, :integer, default: 0
  end
end
