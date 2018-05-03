class AddLocationIdToCaseWorkers < ActiveRecord::Migration[4.2]
  def change
    add_reference :case_workers, :location, index: true
  end
end
