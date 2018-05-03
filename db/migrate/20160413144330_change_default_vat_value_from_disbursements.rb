class ChangeDefaultVatValueFromDisbursements < ActiveRecord::Migration[4.2]
  def up
    change_column_default :disbursements, :vat_amount, nil
  end

  def down
    change_column_default :disbursements, :vat_amount, 0.0
  end
end
