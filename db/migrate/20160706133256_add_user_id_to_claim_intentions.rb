class AddUserIdToClaimIntentions < ActiveRecord::Migration[4.2]
  def change
    add_column :claim_intentions, :user_id, :integer
  end
end
