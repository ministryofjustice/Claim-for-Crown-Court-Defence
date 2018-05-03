class AddDateRequiredFieldsToCaseType < ActiveRecord::Migration[4.2]
  def change
    add_column :case_types, :requires_cracked_dates, :boolean
    add_column :case_types, :requires_trial_dates, :boolean
  end
end
