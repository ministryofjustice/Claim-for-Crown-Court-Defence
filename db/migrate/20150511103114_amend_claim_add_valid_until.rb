class AmendClaimAddValidUntil < ActiveRecord::Migration
  def change
    change_table(:claims) do |t|
      t.datetime :valid_until
    end
    add_index :claims, :valid_until
  end
end
