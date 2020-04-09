class AddTrialStartedToClaims < ActiveRecord::Migration[6.0]
  def change
    add_column :claims, :trial_started, :boolean, default: nil
    add_index :claims, :trial_started
  end
end
