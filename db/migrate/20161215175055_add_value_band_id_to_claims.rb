class AddValueBandIdToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :value_band_id, :integer, default: nil
  end
end
