class AddInterimFieldsToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :effective_pcmh_date, :date
    add_column :claims, :legal_aid_transfer_date, :date
  end
end
