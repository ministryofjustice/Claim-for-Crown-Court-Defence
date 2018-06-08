class AddClaimIdIndexToDeterminations < ActiveRecord::Migration[5.0]
  def change
    add_index :determinations, :claim_id
  end
end
