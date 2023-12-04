class DropStatistics < ActiveRecord::Migration[6.1]
  def up
    drop_table :statistics
  end


  def down
    create_table :statistics, id: :serial, force: :cascade do |t|
      t.date :date
      t.string :report_name
      t.string :claim_type
      t.integer :value_1
      t.integer :value_2, default: 0
    end

    add_index :statistics,
              [:date, :report_name, :claim_type],
              unique: true,
              name: 'index_statistics_on_date_and_report_name_and_claim_type'
  end
end
