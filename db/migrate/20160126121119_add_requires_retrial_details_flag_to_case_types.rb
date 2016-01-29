class AddRequiresRetrialDetailsFlagToCaseTypes < ActiveRecord::Migration
  def up
    add_column :case_types, :requires_retrial_dates, :boolean, default: false

    # migrate data
    CaseType.find_by(name: 'Retrial').update_column(:requires_retrial_dates,true) rescue nil
  end

  def down
    remove_column :case_types, :requires_retrial_dates
  end
end
