class RemoveApprovalLevelsFromCaseWorker < ActiveRecord::Migration[4.2]
  def change
    remove_column :case_workers, :approval_level, :string, default: 'Low'
  end
end
