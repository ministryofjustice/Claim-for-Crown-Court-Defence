class RemoveDaysWorkedFromCaseWorkers < ActiveRecord::Migration[4.2]
  def change
    remove_column :case_workers, :days_worked
  end
end
