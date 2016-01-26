class AddRequiresRetrialDetailsFlagToCaseTypes < ActiveRecord::Migration
  def change
    add_column :case_types, :requires_retrial_dates, :boolean, default: false
  end
end
