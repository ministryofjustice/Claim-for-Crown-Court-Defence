class Statistics < ActiveRecord::Migration
  def change
    create_table :statistics do |t|
      t.date :date
      t.string :report_name
      t.string :claim_type
      t.integer :value_1
    end

    add_index :statistics, [:date, :report_name, :claim_type], unique: true
  end
end
