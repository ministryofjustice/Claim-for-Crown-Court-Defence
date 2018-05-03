class AddGradFeeCodeToCaseTypes < ActiveRecord::Migration[4.2]
  def change
    add_column :case_types, :grad_fee_code, :string
  end
end
