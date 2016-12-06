class AddDiskEvidenceToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :disk_evidence, :boolean, default: false
  end
end
