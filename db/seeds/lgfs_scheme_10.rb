require Rails.root.join('db','seeds', 'schemas', 'add_lgfs_fee_scheme_10')
require Rails.root.join('db','seeds', 'schemas', 'clean_lgfs_fee_scheme_10')

adder = Seeds::Schemas::AddLgfsFeeScheme10.new(pretend: false)
adder.up
fixer = Seeds::Schemas::CleanLgfsFeeScheme10.new(pretend: false, quiet: true)
fixer.up
