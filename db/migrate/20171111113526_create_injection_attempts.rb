class CreateInjectionAttempts < ActiveRecord::Migration[4.2]
  def change
    create_table :injection_attempts do |t|
      t.references :claim, index: true, foreign_key: true
      t.boolean :succeeded
      t.string :error_message
      t.timestamps null: true
    end
  end
end
