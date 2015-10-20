class AddApplyVatToAdvocates < ActiveRecord::Migration
  def change
    add_column :advocates, :apply_vat, :boolean, default: true
  end
end
