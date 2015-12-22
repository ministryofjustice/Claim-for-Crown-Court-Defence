class RemoveApprovalLevelsFromCaseWorker < ActiveRecord::Migration
  def change
    remove_column :case_workers, :approval_level, :string, default: 'Low'
  end
end
