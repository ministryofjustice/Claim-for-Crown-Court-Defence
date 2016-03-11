class RemoveDaysWorkedFromCaseWorkers < ActiveRecord::Migration
  def change
    remove_column :case_workers, :days_worked
  end
end
