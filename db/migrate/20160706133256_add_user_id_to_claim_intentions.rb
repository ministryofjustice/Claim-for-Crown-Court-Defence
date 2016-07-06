class AddUserIdToClaimIntentions < ActiveRecord::Migration
  def change
    add_column :claim_intentions, :user_id, :integer
  end
end
