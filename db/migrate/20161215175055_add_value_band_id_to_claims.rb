class AddValueBandIdToClaims < ActiveRecord::Migration[4.2]
  def change
    add_column :claims, :value_band_id, :integer, default: nil
  end
end
