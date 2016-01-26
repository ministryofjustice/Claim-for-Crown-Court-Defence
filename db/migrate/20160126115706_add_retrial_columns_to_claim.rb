class AddRetrialColumnsToClaim < ActiveRecord::Migration
  def change
    change_table :claims do |t|
      t.date    :retrial_started_at
      t.integer :retrial_estimated_length, default: 0
      t.integer :retrial_actual_length, default: 0
      t.date    :retrial_concluded_at
    end
  end
end
