class CreateCertifications < ActiveRecord::Migration
  def change
    create_table :certifications do |t|
      t.integer :claim_id
      t.boolean :main_hearing
      t.boolean :notified_court
      t.boolean :attended_pcmh
      t.boolean :attended_first_hearing
      t.boolean :previous_advocate_notified_court
      t.boolean :fixed_fee_case
      t.string  :certified_by
      t.date    :certification_date

      t.timestamps null: true
    end
  end
end
