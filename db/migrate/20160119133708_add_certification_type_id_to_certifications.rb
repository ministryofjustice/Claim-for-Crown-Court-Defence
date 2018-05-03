class AddCertificationTypeIdToCertifications < ActiveRecord::Migration[4.2]
  def change
    add_column :certifications, :certification_type_id, :integer
  end
end
