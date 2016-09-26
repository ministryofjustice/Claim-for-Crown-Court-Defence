class AddUuidToCaseWorker < ActiveRecord::Migration
  def change
    add_column :case_workers, :uuid, :uuid, default: 'uuid_generate_v4()', index: true
  end
end
