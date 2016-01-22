class ModifyFeeTypeCalculatedData < ActiveRecord::Migration
  def up
    FeeType.where(code: ['PPE','NPW']).each do |record|
      record.update_column(:calculated, false)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
