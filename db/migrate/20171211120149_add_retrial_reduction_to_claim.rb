class AddRetrialReductionToClaim < ActiveRecord::Migration[4.2]
  def change
    add_column :claims, :retrial_reduction, :boolean, default: false
  end
end
