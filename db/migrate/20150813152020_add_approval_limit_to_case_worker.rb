class AddApprovalLimitToCaseWorker < ActiveRecord::Migration
  def change
    add_column :case_workers, :approval_level, :string, default: 'Low'
  end
end
