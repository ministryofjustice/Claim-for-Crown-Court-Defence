class AddCertificationTypeIdToCertification < ActiveRecord::Migration
  def change
    add_column :certifications, :certification_type_id, :integer
  end
end
