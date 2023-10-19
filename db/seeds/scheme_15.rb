require Rails.root.join('db','seeds', 'schemas', 'add_agfs_fee_scheme_15')
# require Rails.root.join('db','seeds', 'schemas', 'clean_agfs_offences')

adder = Seeds::Schemas::AddAGFSFeeScheme15.new(pretend: false)
adder.up
# TODO: Update setup script to clean up offences after fee scheme 15 has been created
# fixer = Seeds::Schemas::CleanAgfsOffences.new(pretend: false, quiet: true)
# fixer.merge_12
# fixer.merge_13
# fixer.merge_11
# fixer.remove_redundant
