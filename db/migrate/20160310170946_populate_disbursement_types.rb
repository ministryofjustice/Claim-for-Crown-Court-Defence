class PopulateDisbursementTypes < ActiveRecord::Migration
  def up
    DisbursementType.destroy_all
    load File.join(Rails.root, 'db', 'seeds', 'disbursement_types.rb')
  end

  def down
    DisbursementType.destroy_all
  end
end
