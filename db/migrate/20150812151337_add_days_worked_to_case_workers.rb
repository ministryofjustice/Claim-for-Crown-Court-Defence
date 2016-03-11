class AddDaysWorkedToCaseWorkers < ActiveRecord::Migration
  def change
    add_column :case_workers, :days_worked, :string
  end
end
