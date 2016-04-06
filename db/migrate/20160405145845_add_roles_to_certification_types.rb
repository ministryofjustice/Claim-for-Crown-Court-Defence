class AddRolesToCertificationTypes < ActiveRecord::Migration
  def change
    add_column :certification_types, :roles, :string

    CertificationType.all.each do |certification_type|
      if certification_type.roles.empty?
        certification_type.roles << 'agfs'
        certification_type.save!
      end
    end
  end
end
