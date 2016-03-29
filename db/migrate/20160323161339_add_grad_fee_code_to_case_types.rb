class AddGradFeeCodeToCaseTypes < ActiveRecord::Migration
  def change
    add_column :case_types, :grad_fee_code, :string
  end
end
