class ChangeDefaultVatValueFromDisbursements < ActiveRecord::Migration
  def up
    change_column_default :disbursements, :vat_amount, nil
  end

  def down
    change_column_default :disbursements, :vat_amount, 0.0
  end
end
