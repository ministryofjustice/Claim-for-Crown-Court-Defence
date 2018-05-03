class RemoveMiddleNameFromDefendants < ActiveRecord::Migration[4.2]
  def change
    remove_column :defendants, :middle_name
  end
end
