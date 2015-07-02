class AddLocationIdToCaseWorkers < ActiveRecord::Migration
  def change
    add_reference :case_workers, :location, index: true
  end
end
