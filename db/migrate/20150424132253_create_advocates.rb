class CreateAdvocates < ActiveRecord::Migration
  def change
    create_table :advocates do |t|
      t.references :chamber, index: true

      t.timestamps
    end
  end
end
