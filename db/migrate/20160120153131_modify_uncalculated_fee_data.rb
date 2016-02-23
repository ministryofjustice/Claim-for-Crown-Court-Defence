class ModifyUncalculatedFeeData < ActiveRecord::Migration
  def up
    Fee::BasicFee.joins(:fee_type).where(fee_types: { code: ['PPE','NPW'] }).where('fees.rate > 0').each do |fee|
      fee.update_column(:rate, 0)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
