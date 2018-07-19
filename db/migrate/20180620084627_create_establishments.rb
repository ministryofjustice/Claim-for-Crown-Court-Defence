class CreateEstablishments < ActiveRecord::Migration[5.0]
  def change
    create_table :establishments do |t|
      t.string :name
      t.string :category, index: true
      t.string :postcode
      t.timestamps
    end
  end
end
