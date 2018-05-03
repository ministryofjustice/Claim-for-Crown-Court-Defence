class AddApplyVatToAdvocates < ActiveRecord::Migration[4.2]
  def change
    add_column :advocates, :apply_vat, :boolean, default: true
  end
end
