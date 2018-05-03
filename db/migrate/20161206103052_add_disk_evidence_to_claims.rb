class AddDiskEvidenceToClaims < ActiveRecord::Migration[4.2]
  def change
    add_column :claims, :disk_evidence, :boolean, default: false
  end
end
