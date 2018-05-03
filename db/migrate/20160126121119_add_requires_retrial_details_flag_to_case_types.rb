class AddRequiresRetrialDetailsFlagToCaseTypes < ActiveRecord::Migration[4.2]
  def up
    add_column :case_types, :requires_retrial_dates, :boolean, default: false
    retrial = CaseType.find_by_sql("SELECT * FROM case_types WHERE name = 'Retrial'").first
    retrial.update_column(:requires_retrial_dates,true) rescue nil
  end

  def down
    remove_column :case_types, :requires_retrial_dates
  end
end
