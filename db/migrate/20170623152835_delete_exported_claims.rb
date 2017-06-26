class DeleteExportedClaims < ActiveRecord::Migration
  def change
    drop_table :exported_claims
  end
end
