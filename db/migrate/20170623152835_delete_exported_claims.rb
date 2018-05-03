class DeleteExportedClaims < ActiveRecord::Migration[4.2]
  def change
    drop_table :exported_claims
  end
end
