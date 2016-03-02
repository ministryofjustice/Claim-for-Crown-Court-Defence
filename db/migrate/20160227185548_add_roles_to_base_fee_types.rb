class AddRolesToBaseFeeTypes < ActiveRecord::Migration
  def change
    add_column :fee_types, :roles, :string

    Fee::BaseFeeType.all.each do |fee_type|
      fee_type.roles << 'agfs'
      fee_type.save!
    end
  end
end
