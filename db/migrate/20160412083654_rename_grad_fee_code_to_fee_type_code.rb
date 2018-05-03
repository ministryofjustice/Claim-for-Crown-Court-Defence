class RenameGradFeeCodeToFeeTypeCode < ActiveRecord::Migration[4.2]
  def change
    rename_column :case_types, :grad_fee_code, :fee_type_code
  end
end
