class UpdateGraduatedFeeTypeCalculated < ActiveRecord::Migration
  def up
     Fee::GraduatedFeeType.update_all(calculated: false)
  end

  def down
     Fee::GraduatedFeeType.update_all(calculated: true)
  end
end
