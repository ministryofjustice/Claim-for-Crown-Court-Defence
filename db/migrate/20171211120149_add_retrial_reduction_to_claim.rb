class AddRetrialReductionToClaim < ActiveRecord::Migration
  def change
    add_column :claims, :retrial_reduction, :boolean, default: false
  end
end
