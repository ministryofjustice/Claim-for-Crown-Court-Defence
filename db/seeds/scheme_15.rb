require Rails.root.join('db','seeds', 'schemas', 'add_agfs_fee_scheme_15')

adder = Seeds::Schemas::AddAgfsFeeScheme15.new(pretend: false)
adder.up
