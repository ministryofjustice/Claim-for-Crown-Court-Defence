class AddRolesToCaseType < ActiveRecord::Migration[4.2]
  def change
    add_column :case_types, :roles, :string

    CaseType.reset_column_information

    case_types = CaseType.find_by_sql("select * from case_types")
    case_types.each do |ct|
      ct.roles << 'agfs'
      ct.roles << 'lgfs'
      ct.save!
    end
  end
end
