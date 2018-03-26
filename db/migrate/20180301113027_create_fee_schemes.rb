class CreateFeeSchemes < ActiveRecord::Migration
  def change
    create_table :fee_schemes do |t|
      t.string :name
      t.integer :version
      t.datetime :start_date
      t.datetime :end_date, default: nil

      t.timestamps null: false
    end
  end
end
