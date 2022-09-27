class CreateFeatureFlag < ActiveRecord::Migration[6.1]
  def change
    create_table :feature_flags do |t|
      t.boolean :enable_new_monarch, null: false, default: false

      t.timestamps
    end
  end
end
