class CreateFeeSchemes < ActiveRecord::Migration
  def change
    create_table :fee_schemes do |t|
      t.integer :number
      t.string :name
      t.datetime :start_date
      t.datetime :end_date, default: nil

      t.timestamps null: false
    end

    FeeScheme.create(number: 9, name: 'LGFS', start_date: '2014-03-20 00:00:00')
    FeeScheme.create(number: 9, name: 'AGFS', start_date: '2012-04-01 00:00:00', end_date: '2018-03-31 23:59:59')
    FeeScheme.create(number: 10, name: 'AGFS', start_date: '2018-04-01 00:00:00')

  end
end
