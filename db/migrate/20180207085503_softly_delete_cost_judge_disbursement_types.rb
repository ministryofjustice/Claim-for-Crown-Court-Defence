class SoftlyDeleteCostJudgeDisbursementTypes < ActiveRecord::Migration
  def up
    DisbursementType.where(unique_code: %i[CJP CJA]).each {|d| d.soft_delete }
  end

  def down
    DisbursementType.where(unique_code: %i[CJP CJA]).each {|d| d.update(deleted_at: nil) }
  end
end
