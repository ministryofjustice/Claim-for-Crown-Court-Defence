class AddCalculatedToFeeType < ActiveRecord::Migration
  def change
    add_column :fee_types, :calculated, :boolean, default: true
  end

  # migrate the existing fee type data
  FeeType.where(code: ['PPE','NPW']) do |record|
      record.update_column(calculated: false)
  end

end
