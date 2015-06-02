class AddDateToToDatesAttended < ActiveRecord::Migration
  def change
    add_column :dates_attended, :date_to, :datetime
  end
end
