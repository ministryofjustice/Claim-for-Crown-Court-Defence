class CreateInjectionAttempts < ActiveRecord::Migration
  def change
    create_table :injection_attempts do |t|
      t.references :claim, index: true, foreign_key: true
      t.boolean :succeeded
      t.string :error_message
      t.timestamps
    end
  end
end
