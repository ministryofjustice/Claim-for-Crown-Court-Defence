require Rails.root.join('db','seeds', 'schemas', 'clean_agfs_offences')

fixer = Seeds::Schemas::CleanAgfsOffences.new(pretend: false, quiet: true)
fixer.merge_12
fixer.merge_13
fixer.merge_11
fixer.remove_redundant
