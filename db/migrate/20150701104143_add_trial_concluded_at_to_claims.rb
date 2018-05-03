class AddTrialConcludedAtToClaims < ActiveRecord::Migration[4.2]
  def change
    add_column :claims, :trial_concluded_at, :date
  end
end
