class AddCalculationToFeeTypes < ActiveRecord::Migration[4.2]
  def up
    add_column :fee_types, :calculated, :boolean, default: true

    fee_types = ActiveRecord::Base.connection.execute("SELECT * FROM fee_types WHERE code IN ('PPE', 'NPW')")

    fee_types.each do |record|
      ActiveRecord::Base.connection.execute("UPDATE fee_types SET calculated = 0 WHERE id = #{record['id']}")      
    end
  end

  def down
    drop_column :fee_types, :calculated
  end
end
