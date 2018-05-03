class AddDaysWorkedToCaseWorkers < ActiveRecord::Migration[4.2]
  def change
    add_column :case_workers, :days_worked, :string
  end
end
