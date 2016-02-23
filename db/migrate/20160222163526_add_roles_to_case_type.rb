class AddRolesToCaseType < ActiveRecord::Migration
  def change
    add_column :case_types, :roles, :string

    CaseType.reset_column_information

    CaseType.all.each do |ct|
      ct.roles << 'agfs'
      ct.save
    end
  end
end
