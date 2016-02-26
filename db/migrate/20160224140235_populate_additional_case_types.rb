class PopulateAdditionalCaseTypes < ActiveRecord::Migration
  def up
    CaseType.reset_column_information
    load File.join Rails.root, 'db', 'seeds', 'case_types.rb'
  end

  def down
    lgfs_case_types = CaseType.lgfs
    agfs_case_types = CaseType.agfs
    lgfs_only_case_types = lgfs_case_types - agfs_case_types
    CaseType.destroy(lgfs_only_case_types.map(&:id))
  end
end
