class AddPriorityToFeeTypes < ActiveRecord::Migration
  def change
    add_column :fee_types, :position, :integer
  end
end
