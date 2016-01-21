class AddCalculationToFeeTypes < ActiveRecord::Migration
  def up
    add_column :fee_types, :calculated, :boolean, default: true

    FeeType.where(code: ['PPE','NPW']) do |record|
        record.update_column(calculated: false)
    end
  end

  def down
    drop_column :fee_types, :calculated
  end
 end
