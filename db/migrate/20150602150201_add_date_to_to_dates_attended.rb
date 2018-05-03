class AddDateToToDatesAttended < ActiveRecord::Migration[4.2]
  def change
    add_column :dates_attended, :date_to, :datetime
  end
end
