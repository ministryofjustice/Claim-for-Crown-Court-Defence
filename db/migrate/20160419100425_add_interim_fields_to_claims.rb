class AddInterimFieldsToClaims < ActiveRecord::Migration[4.2]
  def change
    add_column :claims, :effective_pcmh_date, :date
    add_column :claims, :legal_aid_transfer_date, :date
  end
end
