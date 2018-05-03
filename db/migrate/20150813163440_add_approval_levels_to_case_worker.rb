class AddApprovalLevelsToCaseWorker < ActiveRecord::Migration[4.2]
  def change
    add_column :case_workers, :approval_level, :string, default: 'Low'
  end
end
