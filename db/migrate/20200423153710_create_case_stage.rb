class CreateCaseStage < ActiveRecord::Migration[6.0]
  def change
    create_table :case_stages do |t|
      t.belongs_to :case_type
      t.string :unique_code, unique: true, null: false, default: ''
      t.string :description, null: false
      t.integer :position
      t.string :roles
    end

    add_belongs_to :claims, :case_stage, null: true, index: true, foreign_key: { name: 'fk_claims_case_stage_id' }
  end
end
