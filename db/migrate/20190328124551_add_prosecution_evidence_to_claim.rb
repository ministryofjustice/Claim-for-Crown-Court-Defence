class AddProsecutionEvidenceToClaim < ActiveRecord::Migration[5.2]
  def change
    add_column :claims, :prosecution_evidence, :boolean, default: nil
  end
end
