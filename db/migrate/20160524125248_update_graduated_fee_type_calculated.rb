class UpdateGraduatedFeeTypeCalculated < ActiveRecord::Migration[4.2]
  def up
     Fee::GraduatedFeeType.update_all(calculated: false)
  end

  def down
     Fee::GraduatedFeeType.update_all(calculated: true)
  end
end
