class CreateClaims < ActiveRecord::Migration
  def change
    create_table :claims do |t|
      t.references :advocate, index: true

      t.timestamps
    end
  end
end
