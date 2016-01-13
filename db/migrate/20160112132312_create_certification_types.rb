class CreateCertificationTypes < ActiveRecord::Migration
  def change
    create_table :certification_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
