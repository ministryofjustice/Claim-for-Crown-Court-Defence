class AddAssessmentBreakDownToMIData < ActiveRecord::Migration[5.0]
  def change
    add_column :mi_data, :assessment_fees, :decimal
    add_column :mi_data, :assessment_expenses, :decimal
    add_column :mi_data, :assessment_disbursements, :decimal
  end
end
