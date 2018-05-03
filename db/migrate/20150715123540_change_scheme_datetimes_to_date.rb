class ChangeSchemeDatetimesToDate < ActiveRecord::Migration[4.2]
  def up
    change_column :schemes, :start_date, :date
    change_column :schemes, :end_date, :date
  end

  def down
    change_column :schemes, :start_date, :datetime
    change_column :schemes, :end_date, :datetime
  end
end
