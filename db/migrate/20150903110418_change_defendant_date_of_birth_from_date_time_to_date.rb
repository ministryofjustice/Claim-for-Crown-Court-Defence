class ChangeDefendantDateOfBirthFromDateTimeToDate < ActiveRecord::Migration[4.2]
  def up
    change_column :defendants, :date_of_birth, :date
    change_column :dates_attended, :date, :date
    change_column :dates_attended, :date_to, :date
  end

  def down
    change_column :defendants, :date_of_birth, :datetime
    change_column :dates_attended, :date, :datetime
    change_column :dates_attended, :date_to, :datetime
  end
end
