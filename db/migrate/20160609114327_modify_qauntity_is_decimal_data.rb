class ModifyQauntityIsDecimalData < ActiveRecord::Migration
  # this reruns the modified task which has added the RNL fee type code
  def up
    Rake::Task['data:migrate:set_quantity_is_decimal'].invoke
  end
end
