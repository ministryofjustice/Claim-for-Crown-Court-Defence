class CreateTransferDetails < ActiveRecord::Migration
  def change
    create_table :transfer_details do |t|
      t.integer :claim_id
      t.string :litigator_type
      t.boolean :elected_case
      t.integer :transfer_stage_id
      t.date :transfer_date
      t.integer :case_conclusion_id
    end
  end
end
