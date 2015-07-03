class AddTrialColumnsToClaims < ActiveRecord::Migration
   def change
    add_column :claims, :trial_fixed_notice_at,   :date
    add_column :claims, :trial_fixed_at,          :date
    add_column :claims, :trial_cracked_at,        :date
    add_column :claims, :trial_cracked_at_third,  :string
  end
end
