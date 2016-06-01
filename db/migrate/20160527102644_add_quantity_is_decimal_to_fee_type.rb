class AddQuantityIsDecimalToFeeType < ActiveRecord::Migration
  def up
    add_column :fee_types, :quantity_is_decimal, :boolean, default: false
    Fee::BaseFeeType.reset_column_information
    Rake::Task['data:migrate:set_quantity_is_decimal'].invoke
  end

  def down
    remove_column :fee_types, :quantity_is_decimal
  end
end
