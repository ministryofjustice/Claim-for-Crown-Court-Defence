require Rails.root.join('db','seeds', 'schemas', 'add_agfs_fee_scheme_13')

adder = Seeds::Schemas::AddAgfsFeeScheme13.new(pretend: false)
adder.up
