class CreateCertificationTypes < ActiveRecord::Migration
  def change
    create_table :certification_types do |t|
      t.string :name, index: true
      t.boolean :pre_may_2015, default: false

      t.timestamps null: true
    end
  end
end
