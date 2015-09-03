class ChangeDefendantDateOfBirthFromDateTimeToDate < ActiveRecord::Migration
  def up
    change_column :defendants, :date_of_birth, :date
  end

  def up
    change_column :defendants, :date_of_birth, :datetime
  end
end
