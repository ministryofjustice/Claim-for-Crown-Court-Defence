class AddRolesToCertificationTypes < ActiveRecord::Migration[4.2]
  def change
    return if ActiveRecord::Base.connection.column_exists?(:certification_types, :roles)

    add_column :certification_types, :roles, :string

    CertificationType.all.each do |certification_type|
      if certification_type.roles.empty?
        certification_type.roles << 'agfs'
        certification_type.save!
      end
    end

    CertificationType.find_or_create_by!(name: 'LGFS certification', roles: ['lgfs'])
  end
end
