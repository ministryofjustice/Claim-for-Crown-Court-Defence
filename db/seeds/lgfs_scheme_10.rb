require Rails.root.join('db','seeds', 'schemas', 'add_lgfs_fee_scheme_10')

adder = Seeds::Schemas::AddLgfsFeeScheme10.new(pretend: false)
adder.up
