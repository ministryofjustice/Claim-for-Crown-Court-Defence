class AddUuidToCaseWorker < ActiveRecord::Migration[4.2]
  def change
    add_column :case_workers, :uuid, :uuid, default: 'uuid_generate_v4()', index: true
  end
end
