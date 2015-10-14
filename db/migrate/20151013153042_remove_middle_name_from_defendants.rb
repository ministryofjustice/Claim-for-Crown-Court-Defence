class RemoveMiddleNameFromDefendants < ActiveRecord::Migration
  def change
    remove_column :defendants, :middle_name
  end
end
