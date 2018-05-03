class AddPriorityToFeeTypes < ActiveRecord::Migration[4.2]
  def change
    add_column :fee_types, :position, :integer
  end
end
