class AddTrialConcludedAtToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :trial_concluded_at, :date
  end
end
