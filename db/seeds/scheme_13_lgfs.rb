require Rails.root.join('db','seeds', 'schemas', 'add_lgfs_fee_scheme_13')

adder = Seeds::Schemas::AddLgfsFeeScheme13.new(pretend: false)
adder.up
